public class Patient extends User {
    private String dateOfBirth;
    private boolean isHIVPositive;
    private String diagnosisDate;
    private boolean onART;
    private String artStartDate;
    private String country;

    public Patient(String firstName, String lastName, String email, String password, String dateOfBirth,
                   boolean isHIVPositive, String diagnosisDate, boolean onART, String artStartDate, String country) {
        super(firstName, lastName, email, password);
        this.dateOfBirth = dateOfBirth;
        this.isHIVPositive = isHIVPositive;
        this.diagnosisDate = diagnosisDate;
        this.onART = onART;
        this.artStartDate = artStartDate;
        this.country = country;
    }

    @Override
    public UserRole getRole() {
        return UserRole.PATIENT;
    }
}
