package service;

import dao.UserDao;
import model.User;
import util.MD5;

public class AuthService {
    private final UserDao userDao = new UserDao();

    public User checkLogin(String account, String password) {
        User user = userDao.getUserByAccount(account);

        if (user == null || isLocked(user)) {
            return null;
        }

        String storedPassword = user.getPassword();
        String hashedPassword = MD5.hash(password);

        if (hashedPassword.equals(storedPassword) || password.equals(storedPassword)) {
            user.setPassword(null);
            return user;
        }

        return null;
    }

    public User getUserByEmail(String email) {
        return userDao.getUserByEmail(email);
    }

    public User getUserByAccount(String account) {
        return userDao.getUserByAccount(account);
    }

    public User getUserById(int userId) {
        return userDao.getUserById(userId);
    }

    public boolean emailExists(String email) {
        return userDao.getUserByEmail(email) != null;
    }

    public void register(String fullName, String email, String password) {
        userDao.insertUser(fullName, email, MD5.hash(password));
    }

    public void updatePassword(String email, String password) {
        userDao.updatePassword(email, MD5.hash(password));
    }

    public void updateUser(User user) {
        userDao.updateUser(user);
    }

    public boolean isLocked(User user) {
        return user != null && "LOCKED".equalsIgnoreCase(user.getStatus());
    }
}
