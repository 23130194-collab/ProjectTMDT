package service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URI;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Properties;

/**
 * Service xử lý toàn bộ luồng Google OAuth 2.0 (Authorization Code Flow)
 */
public class GoogleOAuthService {

    private static String CLIENT_ID = "183680477500-f523c4gkktdp6at2qf9bnhrdcapio7aa.apps.googleusercontent.com";
    private static String CLIENT_SECRET = "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";
    private static String REDIRECT_URI = "http://localhost:8080/ProjectTMDT_war_exploded/login-google";

    private static final String AUTH_ENDPOINT = "https://accounts.google.com/o/oauth2/v2/auth";
    private static final String TOKEN_ENDPOINT = "https://oauth2.googleapis.com/token";
    private static final String USERINFO_ENDPOINT = "https://www.googleapis.com/oauth2/v3/userinfo";

    private static final ObjectMapper MAPPER = new ObjectMapper();

    static {
        loadConfig();
    }

    private static void loadConfig() {
        try (InputStream in = GoogleOAuthService.class.getClassLoader().getResourceAsStream("google-oauth.properties")) {
            if (in != null) {
                Properties props = new Properties();
                props.load(in);
                if (props.getProperty("google.client.id") != null && !props.getProperty("google.client.id").trim().isEmpty()) {
                    CLIENT_ID = props.getProperty("google.client.id").trim();
                }
                if (props.getProperty("google.client.secret") != null && !props.getProperty("google.client.secret").trim().isEmpty()) {
                    CLIENT_SECRET = props.getProperty("google.client.secret").trim();
                }
                if (props.getProperty("google.redirect.uri") != null && !props.getProperty("google.redirect.uri").trim().isEmpty()) {
                    REDIRECT_URI = props.getProperty("google.redirect.uri").trim();
                }
            }
        } catch (Exception ignored) {
        }
    }

    public static String buildAuthorizationUrl(String state) {
        return AUTH_ENDPOINT + "?"
                + "client_id=" + urlEncode(CLIENT_ID)
                + "&redirect_uri=" + urlEncode(REDIRECT_URI)
                + "&response_type=code"
                + "&scope=" + urlEncode("openid email profile")
                + "&state=" + urlEncode(state)
                + "&access_type=offline"
                + "&prompt=select_account";
    }

    public static String exchangeCodeForAccessToken(String code) throws IOException {
        String body = "code=" + urlEncode(code)
                + "&client_id=" + urlEncode(CLIENT_ID)
                + "&client_secret=" + urlEncode(CLIENT_SECRET)
                + "&redirect_uri=" + urlEncode(REDIRECT_URI)
                + "&grant_type=authorization_code";

        URL url = URI.create(TOKEN_ENDPOINT).toURL();
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("POST");
        conn.setDoOutput(true);
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        conn.setConnectTimeout(10000);
        conn.setReadTimeout(10000);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(body.getBytes(StandardCharsets.UTF_8));
        }

        int status = conn.getResponseCode();
        InputStream is = (status >= 200 && status < 300) ? conn.getInputStream() : conn.getErrorStream();

        JsonNode root = MAPPER.readTree(is);
        if (root.has("access_token")) {
            return root.get("access_token").asText();
        } else if (root.has("error_description")) {
            throw new IOException("Lỗi Google OAuth: " + root.get("error_description").asText());
        } else if (root.has("error")) {
            throw new IOException("Lỗi Google OAuth: " + root.get("error").asText());
        } else {
            throw new IOException("Không lấy được access_token từ Google: " + root.toString());
        }
    }

    public static GoogleUserInfo getUserInfo(String accessToken) throws IOException {
        URL url = URI.create(USERINFO_ENDPOINT).toURL();
        HttpURLConnection conn = (HttpURLConnection) url.openConnection();
        conn.setRequestMethod("GET");
        conn.setRequestProperty("Authorization", "Bearer " + accessToken);
        conn.setRequestProperty("Accept", "application/json");
        conn.setConnectTimeout(10000);
        conn.setReadTimeout(10000);

        int status = conn.getResponseCode();
        if (status != 200) {
            throw new IOException("Không lấy được thông tin user từ Google. HTTP status: " + status);
        }

        try (InputStream is = conn.getInputStream()) {
            JsonNode root = MAPPER.readTree(is);
            GoogleUserInfo user = new GoogleUserInfo();
            user.setId(root.path("sub").asText(null));
            user.setEmail(root.path("email").asText(null));
            user.setEmailVerified(root.path("email_verified").asBoolean(false));
            user.setName(root.path("name").asText(null));
            user.setGivenName(root.path("given_name").asText(null));
            user.setFamilyName(root.path("family_name").asText(null));
            user.setPicture(root.path("picture").asText(null));
            return user;
        }
    }

    private static String urlEncode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }

    public static class GoogleUserInfo {
        private String id;
        private String email;
        private boolean emailVerified;
        private String name;
        private String givenName;
        private String familyName;
        private String picture;

        public String getId() { return id; }
        public void setId(String id) { this.id = id; }
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public boolean isEmailVerified() { return emailVerified; }
        public void setEmailVerified(boolean emailVerified) { this.emailVerified = emailVerified; }
        public String getName() { return name; }
        public void setName(String name) { this.name = name; }
        public String getGivenName() { return givenName; }
        public void setGivenName(String givenName) { this.givenName = givenName; }
        public String getFamilyName() { return familyName; }
        public void setFamilyName(String familyName) { this.familyName = familyName; }
        public String getPicture() { return picture; }
        public void setPicture(String picture) { this.picture = picture; }
    }
}
