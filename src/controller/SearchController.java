package controller;

import dao.ProductDAO;
import model.Product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "SearchController", value = "/search")
public class SearchController extends HttpServlet {
    private static final String HISTORY_KEY = "searchHistory";
    private static final int HISTORY_LIMIT = 5;
    private final ProductDAO productDAO = new ProductDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("suggest".equals(action)) {
            String keyword = normalize(request.getParameter("q"));
            List<Product> suggestions = keyword.length() < 2
                    ? new ArrayList<>() : productDAO.getProductSuggestions(keyword);
            writeProductSuggestionsJson(response, suggestions);
            return;
        }
        if ("history".equals(action)) {
            writeJson(response, "history", getHistory(request.getSession(false)));
            return;
        }

        String keyword = normalize(request.getParameter("q"));
        if (!keyword.isEmpty()) {
            rememberSearch(request.getSession(), keyword);
        }
        List<Product> products = keyword.isEmpty()
                ? productDAO.getRecentProducts() : productDAO.searchProducts(keyword);
        request.setAttribute("products", products);
        request.setAttribute("searchKeyword", keyword);
        request.getRequestDispatcher("01-trang-chu.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws IOException {
        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");
        HttpSession session = request.getSession(false);
        List<String> history = getHistory(session);

        if ("delete".equals(action)) {
            String term = normalize(request.getParameter("term"));
            history.removeIf(item -> item.equalsIgnoreCase(term));
        } else if ("clear".equals(action)) {
            history.clear();
        }

        if (session != null) {
            session.setAttribute(HISTORY_KEY, history);
        }
        writeJson(response, "history", history);
    }

    @SuppressWarnings("unchecked")
    private List<String> getHistory(HttpSession session) {
        if (session == null) return new ArrayList<>();
        Object value = session.getAttribute(HISTORY_KEY);
        if (value instanceof List<?>) return (List<String>) value;
        return new ArrayList<>();
    }

    private void rememberSearch(HttpSession session, String keyword) {
        List<String> history = getHistory(session);
        history.removeIf(item -> item.equalsIgnoreCase(keyword));
        history.add(0, keyword);
        if (history.size() > HISTORY_LIMIT) {
            history.subList(HISTORY_LIMIT, history.size()).clear();
        }
        session.setAttribute(HISTORY_KEY, history);
    }

    private String normalize(String value) {
        if (value == null) return "";
        String normalized = value.trim().replaceAll("\\s+", " ");
        return normalized.length() > 100 ? normalized.substring(0, 100) : normalized;
    }

    private void writeJson(HttpServletResponse response, String key, List<String> values) throws IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");
        StringBuilder json = new StringBuilder("{\"").append(key).append("\":[");
        for (int i = 0; i < values.size(); i++) {
            if (i > 0) json.append(',');
            json.append('"').append(escapeJson(values.get(i))).append('"');
        }
        json.append("]}");
        response.getWriter().write(json.toString());
    }

    private void writeProductSuggestionsJson(HttpServletResponse response, List<Product> products) throws IOException {
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json;charset=UTF-8");
        response.setHeader("Cache-Control", "no-store");
        StringBuilder json = new StringBuilder("{\"suggestions\":[");
        for (int i = 0; i < products.size(); i++) {
            if (i > 0) json.append(',');
            Product product = products.get(i);
            json.append("{\"title\":\"").append(escapeJson(product.getTitle()))
                    .append("\",\"price\":").append(product.getPrice()).append('}');
        }
        json.append("]}");
        response.getWriter().write(json.toString());
    }

    private String escapeJson(String value) {
        StringBuilder escaped = new StringBuilder();
        for (int i = 0; i < value.length(); i++) {
            char ch = value.charAt(i);
            switch (ch) {
                case '"': escaped.append("\\\""); break;
                case '\\': escaped.append("\\\\"); break;
                case '\b': escaped.append("\\b"); break;
                case '\f': escaped.append("\\f"); break;
                case '\n': escaped.append("\\n"); break;
                case '\r': escaped.append("\\r"); break;
                case '\t': escaped.append("\\t"); break;
                default:
                    if (ch < 0x20) escaped.append(String.format("\\u%04x", (int) ch));
                    else escaped.append(ch);
            }
        }
        return escaped.toString();
    }
}
