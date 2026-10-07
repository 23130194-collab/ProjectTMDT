package service;

import dao.UserDao;
import model.User;

import java.util.List;

public class UserService {
    private final UserDao userDao = new UserDao();

    public User getUserByEmail(String email) {
        return userDao.getUserByEmail(email);
    }

    public void insertUser(String name, String email, String password) {
        userDao.insertUser(name, email, password);
    }

    public void activateUser(int userId) {
        userDao.updateUserStatus(userId, "ACTIVE");
    }

    public void updateUser(User user) {
        userDao.updateUser(user);
    }

    public void updateUserStatus(int userId, String newStatus) {
        userDao.updateUserStatus(userId, newStatus);
    }

    public String getUserStatus(int userId) {
        return userDao.getUserStatus(userId);
    }

    public int countCustomersByFilter(String status, String keyword) {
        return userDao.countCustomersByFilter(status, keyword);
    }

    public List<User> getCustomersPaging(int limit, int offset, String status, String keyword) {
        return userDao.getCustomersPaging(limit, offset, status, keyword);
    }

    public int getTotalCustomersCount() {
        return userDao.getTotalCustomersCount();
    }

    public int getNewCustomersThisMonth() {
        return userDao.getNewCustomersThisMonth();
    }

    public void createUser(User user) {
        userDao.createUser(user);
    }

    public User getUserById(int id) {
        return userDao.getUserById(id);
    }

    public void addCustomerByAdmin(String name, String email, String hashedPassword) {
        userDao.insertUserByAdmin(name, email, hashedPassword);
    }

    public int getRoleById(int userId) {
        return userDao.getRoleById(userId);
    }

    public boolean updateRole(int userId, int newRole) {
        return userDao.updateRole(userId, newRole);
    }
}
