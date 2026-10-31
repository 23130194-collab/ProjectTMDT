import os
import io
import torch
from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sentence_transformers import SentenceTransformer
from PIL import Image
import uvicorn

app = FastAPI(title="MuaNgay CLIP Multimodal Visual Search Service")

# Cho phép gọi từ Java/Frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Nạp mô hình clip-ViT-B-32 của OpenAI
print("[AI Service] Dang nap mo hinh clip-ViT-B-32...")
model = SentenceTransformer("clip-ViT-B-32")
print("[AI Service] Da nap mo hinh clip-ViT-B-32 thanh cong!")

# BỘ TỪ ĐIỂN DANH MỤC THỰC THỂ ĐA PHƯƠNG THỨC (Zero-Shot Prompt Ensemble Taxonomy)
TAXONOMY = {
    "noi_nau": {
        "name": "Nồi nấu ăn / Xoong",
        "prompts": [
            "a photo of a cooking pot with two handles",
            "a photo of a deep soup pot with a lid",
            "a photo of a metal stockpot",
            "a photo of an aluminum cooking pot",
            "a photo of a saucepan with two loop handles",
            "nồi nấu ăn inox hoặc nhôm có hai quai cầm",
            "xoong nhôm nấu canh truyền thống"
        ]
    },
    "chao": {
        "name": "Chảo xào / Chảo chiên",
        "prompts": [
            "a photo of a frying pan with a long handle",
            "a photo of a shallow skillet",
            "a photo of a flat frying pan",
            "chảo chống dính có một tay cầm dài",
            "chảo xào rán lòng nông"
        ]
    },
    "noi_com_dien": {
        "name": "Nồi cơm điện",
        "prompts": [
            "a photo of an electric rice cooker",
            "a photo of an electric rice cooker with digital control buttons",
            "nồi cơm điện nắp gài chính hãng",
            "nồi cơm điện tử cao tần"
        ]
    },
    "am_sieu_toc": {
        "name": "Ấm siêu tốc / Bình đun",
        "prompts": [
            "a photo of an electric kettle",
            "ấm đun nước siêu tốc",
            "bình đun siêu tốc bằng điện"
        ]
    },
    "bep": {
        "name": "Bếp điện / Bếp gas",
        "prompts": [
            "a photo of an induction cooker stove",
            "a gas stove",
            "bếp từ đơn hoặc bếp từ đôi",
            "bếp gas gia đình"
        ]
    },
    "dien_thoai": {
        "name": "Điện thoại / Smartphone",
        "prompts": [
            "a photo of a smartphone",
            "điện thoại thông minh apple iphone",
            "smartphone mobile phone"
        ]
    },
    "laptop": {
        "name": "Laptop / Máy tính",
        "prompts": [
            "a photo of a laptop computer",
            "máy tính xách tay macbook",
            "laptop notebook"
        ]
    },
    "thoi_trang": {
        "name": "Thời trang / Quần áo",
        "prompts": [
            "a photo of clothing clothes",
            "quần áo thời trang áo thun áo khoác"
        ]
    },
    "noi_that": {
        "name": "Nội thất / Bàn ghế / Tủ",
        "prompts": [
            "furniture table chair wardrobe",
            "nội thất bàn ghế tủ quần áo giường ngủ"
        ]
    },
    "xe_co": {
        "name": "Xe cộ / Phương tiện",
        "prompts": [
            "a photo of a motorbike motorcycle bicycle",
            "xe máy xe đạp xe cộ phương tiện"
        ]
    }
}

# Tiền mã hóa sẵn vector danh mục vào RAM lúc khởi động bằng phương pháp Prompt Ensemble
print("[AI Service] Dang tien ma hoa vector Zero-Shot Prompt Ensemble Taxonomy...")
TAXONOMY_VECTORS = {}
for key, item in TAXONOMY.items():
    plist = item["prompts"]
    p_vecs = [torch.tensor(model.encode(p, normalize_embeddings=True)) for p in plist]
    mean_v = torch.stack(p_vecs).mean(dim=0)
    mean_v = mean_v / mean_v.norm()
    TAXONOMY_VECTORS[key] = mean_v.tolist()
print(f"[AI Service] Da tien ma hoa thanh cong {len(TAXONOMY_VECTORS)} danh muc thuc the (Prompt Ensemble)!")


def classify_intent(embedding: list) -> dict:
    """Đối soát vector ảnh với bộ từ điển thực thể đa phương thức để dự đoán ý định"""
    emb_tensor = torch.tensor(embedding)
    max_sim = -1.0
    best_key = "san_pham_khac"
    best_name = "Sản phẩm khác"
    all_intents = []

    for key, t_vec in TAXONOMY_VECTORS.items():
        sim = float(torch.dot(emb_tensor, torch.tensor(t_vec)))
        all_intents.append({"intent": key, "name": TAXONOMY[key]["name"], "score": round(sim, 4)})
        if sim > max_sim:
            max_sim = sim
            best_key = key
            best_name = TAXONOMY[key]["name"]

    all_intents.sort(key=lambda x: x["score"], reverse=True)
    return {
        "predicted_intent": best_key,
        "predicted_intent_name": best_name,
        "intent_confidence": round(max_sim, 4),
        "top_intents": all_intents[:3]
    }


@app.get("/health")
def health_check():
    return {
        "status": "ok",
        "model": "clip-ViT-B-32",
        "dimensions": 512,
        "taxonomy_count": len(TAXONOMY_VECTORS)
    }


@app.post("/embed")
async def extract_embedding(file: UploadFile = File(...)):
    """Trích xuất vector 512 chiều và dự đoán ý định thực thể (Zero-Shot Intent)"""
    try:
        contents = await file.read()
        image = Image.open(io.BytesIO(contents)).convert("RGB")
        embedding = model.encode(image, normalize_embeddings=True).tolist()
        intent_info = classify_intent(embedding)

        return {
            "status": "success",
            "filename": file.filename,
            "dimensions": len(embedding),
            "embedding": embedding,
            **intent_info
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Loi xu ly anh: {str(e)}")


@app.post("/embed-path")
def extract_embedding_from_path(image_path: str = Form(...)):
    """Trích xuất vector từ đường dẫn file trên máy"""
    try:
        if not os.path.exists(image_path):
            raise HTTPException(status_code=404, detail="Khong tim thay file anh tren may")
        image = Image.open(image_path).convert("RGB")
        embedding = model.encode(image, normalize_embeddings=True).tolist()
        intent_info = classify_intent(embedding)

        return {
            "status": "success",
            "image_path": image_path,
            "dimensions": len(embedding),
            "embedding": embedding,
            **intent_info
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Loi xu ly anh: {str(e)}")


@app.post("/embed-text")
def extract_text_embedding(text: str = Form(...)):
    """Trích xuất vector từ văn bản (phục vụ đối soát tương đồng ngữ nghĩa)"""
    try:
        embedding = model.encode(text, normalize_embeddings=True).tolist()
        return {
            "status": "success",
            "text": text,
            "dimensions": len(embedding),
            "embedding": embedding
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Loi xu ly text: {str(e)}")


if __name__ == "__main__":
    uvicorn.run("app:app", host="127.0.0.1", port=8000, reload=False)
