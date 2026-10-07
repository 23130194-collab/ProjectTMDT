package service;

import javax.net.ssl.SSLSocketFactory;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStreamWriter;
import java.net.Socket;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

public class EmailService {
    public static boolean sendOtpEmail(String toEmail, String otp) {
        return sendEmail(
                toEmail,
                "Ma OTP xac thuc tai khoan MuaNgay",
                buildOtpHtml(
                        "Chao mung ban den voi MuaNgay!",
                        "Ma OTP de kich hoat tai khoan cua ban la:",
                        otp
                )
        );
    }

    public static boolean sendPasswordResetOtpEmail(String toEmail, String otp) {
        return sendEmail(
                toEmail,
                "Ma OTP dat lai mat khau MuaNgay",
                buildOtpHtml(
                        "Dat lai mat khau MuaNgay",
                        "Ma OTP de dat lai mat khau cua ban la:",
                        otp
                )
        );
    }

    public static void sendContactResponseEmail(String toEmail, String customerName, String originalContent, String responseContent) {
        System.out.println("Contact response email skipped for: " + toEmail);
    }

    public static void sendAdminCreatedAccountEmail(String toEmail, String customerName, String password) {
        System.out.println("Admin created account email skipped for: " + toEmail);
    }

    private static boolean sendEmail(String toEmail, String subject, String body) {
        String host = config("SMTP_HOST");
        String portValue = config("SMTP_PORT");
        String username = config("SMTP_USER");
        String password = config("SMTP_PASSWORD");
        String from = config("SMTP_FROM");

        if (isBlank(host) || isBlank(portValue) || isBlank(username) || isBlank(password)) {
            System.out.println("[DEV EMAIL] To: " + toEmail);
            System.out.println("[DEV EMAIL] Subject: " + subject);
            System.out.println("[DEV EMAIL] OTP content: " + stripHtml(body));
            return false;
        }

        if (isBlank(from)) {
            from = username;
        }

        int port = Integer.parseInt(portValue);
        boolean ssl = "true".equalsIgnoreCase(config("SMTP_SSL")) || port == 465;

        try (Socket socket = ssl
                ? SSLSocketFactory.getDefault().createSocket(host, port)
                : new Socket(host, port)) {
            socket.setSoTimeout(15000);
            SmtpClient client = new SmtpClient(socket);
            client.expect(220);
            client.command("EHLO localhost", 250);

            if (!ssl && !"false".equalsIgnoreCase(config("SMTP_STARTTLS"))) {
                client.command("STARTTLS", 220);
                Socket tlsSocket = ((SSLSocketFactory) SSLSocketFactory.getDefault()).createSocket(
                        socket,
                        host,
                        port,
                        true
                );
                client = new SmtpClient(tlsSocket);
                client.command("EHLO localhost", 250);
            }

            client.command("AUTH LOGIN", 334);
            client.command(Base64.getEncoder().encodeToString(username.getBytes(StandardCharsets.UTF_8)), 334);
            client.command(Base64.getEncoder().encodeToString(password.getBytes(StandardCharsets.UTF_8)), 235);
            client.command("MAIL FROM:<" + from + ">", 250);
            client.command("RCPT TO:<" + toEmail + ">", 250);
            client.command("DATA", 354);
            client.data(from, toEmail, subject, body);
            client.command("QUIT", 221);
            return true;
        } catch (Exception e) {
            System.err.println("Khong the gui email SMTP: " + e.getMessage());
            System.out.println("[DEV EMAIL] To: " + toEmail);
            System.out.println("[DEV EMAIL] Subject: " + subject);
            System.out.println("[DEV EMAIL] OTP content: " + stripHtml(body));
            return false;
        }
    }

    private static String buildOtpHtml(String heading, String intro, String otp) {
        return "<!DOCTYPE html>"
                + "<html><body style=\"margin:0;padding:0;background:#ffffff;font-family:Arial,Helvetica,sans-serif;color:#202124;\">"
                + "<div style=\"max-width:680px;margin:0 auto;padding:48px 32px;\">"
                + "<h1 style=\"font-size:32px;line-height:1.25;margin:0 0 32px;font-weight:700;\">" + heading + "</h1>"
                + "<p style=\"font-size:18px;line-height:1.6;margin:0 0 28px;\">" + intro + "</p>"
                + "<div style=\"font-size:34px;line-height:1.2;margin:0 0 32px;font-weight:800;color:#f4511e;letter-spacing:1px;\">" + otp + "</div>"
                + "<p style=\"font-size:17px;line-height:1.6;margin:0 0 28px;\">Ma nay se het han sau 5 phut.</p>"
                + "<p style=\"font-size:16px;line-height:1.6;margin:0;\">Tran trong,<br>Doi ngu MuaNgay</p>"
                + "</div>"
                + "</body></html>";
    }

    private static String stripHtml(String html) {
        return html.replaceAll("<[^>]+>", " ").replaceAll("\\s+", " ").trim();
    }

    private static String config(String key) {
        String value = System.getProperty(key);
        if (isBlank(value)) {
            value = System.getenv(key);
        }
        return value;
    }

    private static boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private static class SmtpClient {
        private final Socket socket;
        private final BufferedReader reader;
        private final BufferedWriter writer;

        SmtpClient(Socket socket) throws IOException {
            this.socket = socket;
            this.reader = new BufferedReader(new InputStreamReader(socket.getInputStream(), StandardCharsets.UTF_8));
            this.writer = new BufferedWriter(new OutputStreamWriter(socket.getOutputStream(), StandardCharsets.UTF_8));
        }

        void command(String command, int expectedCode) throws IOException {
            writer.write(command + "\r\n");
            writer.flush();
            expect(expectedCode);
        }

        void data(String from, String to, String subject, String body) throws IOException {
            writer.write("From: " + from + "\r\n");
            writer.write("To: " + to + "\r\n");
            writer.write("Subject: " + subject + "\r\n");
            writer.write("MIME-Version: 1.0\r\n");
            writer.write("Content-Type: text/html; charset=UTF-8\r\n");
            writer.write("Content-Transfer-Encoding: 8bit\r\n");
            writer.write("\r\n");
            writer.write(body.replace("\n.", "\n.."));
            writer.write("\r\n.\r\n");
            writer.flush();
            expect(250);
        }

        void expect(int expectedCode) throws IOException {
            String line = reader.readLine();
            if (line == null || !line.startsWith(String.valueOf(expectedCode))) {
                throw new IOException("SMTP expected " + expectedCode + " but got: " + line);
            }
            while (line.length() > 3 && line.charAt(3) == '-') {
                line = reader.readLine();
                if (line == null) {
                    throw new IOException("SMTP response ended unexpectedly");
                }
            }
        }
    }
}
