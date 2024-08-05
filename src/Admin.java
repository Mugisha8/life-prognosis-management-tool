public class Admin extends User {
    public Admin(String firstName, String lastName, String email, String password) {
        super(firstName, lastName, email, password);
    }

    @Override
    public UserRole getRole() {
        return UserRole.ADMIN;
    }
    
}
