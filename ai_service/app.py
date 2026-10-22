import os
import io
from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sentence_transformers import SentenceTransformer
from PIL import Image
import uvicorn

app = FastAPI(title="MuaNgay CLIP Visual Search Service")

# Cho phép gọi từ Java/Frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Nạp mô hình clip-ViT-B-32 của OpenAI (tự động cache vào ~/.cache/huggingface)
print("[AI Service] Dang nap mo hinh clip-ViT-B-32...")
model = SentenceTransformer("clip-ViT-B-32")
print("[AI Service] Da nap mo hinh clip-ViT-B-32 thanh cong!")

@app.get("/health")
def health_check():
    return {"status": "ok", "model": "clip-ViT-B-32", "dimensions": 512}

@app.post("/embed")
async def extract_embedding(file: UploadFile = File(...)):
    """Trích xuất vector 512 chiều từ file ảnh được upload"""
    try:
        contents = await file.read()
        image = Image.open(io.BytesIO(contents)).convert("RGB")
        # Sinh vector chuẩn hóa L2 (normalize_embeddings=True để Cosine Similarity = Dot Product)
        embedding = model.encode(image, normalize_embeddings=True)
        return {
            "status": "success",
            "filename": file.filename,
            "dimensions": len(embedding),
            "embedding": embedding.tolist()
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Loi xu ly anh: {str(e)}")

@app.post("/embed-path")
def extract_embedding_from_path(image_path: str = Form(...)):
    """Trích xuất vector từ đường dẫn file trên ổ đĩa (dùng để đồng bộ hàng loạt cực nhanh)"""
    try:
        if not os.path.exists(image_path):
            raise HTTPException(status_code=404, detail="Khong tim thay file anh tren may")
        image = Image.open(image_path).convert("RGB")
        embedding = model.encode(image, normalize_embeddings=True)
        return {
            "status": "success",
            "image_path": image_path,
            "dimensions": len(embedding),
            "embedding": embedding.tolist()
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Loi xu ly anh: {str(e)}")

if __name__ == "__main__":
    uvicorn.run("app:app", host="127.0.0.1", port=8000, reload=False)
