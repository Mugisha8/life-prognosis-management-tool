import java.util.Scanner;
import java.io.IOException;

public class Kalisimbi_App {

    public static void main(String[] args) {
        Scanner scanner = new Scanner(System.in);
        while (true) {
            System.out.println("WELCOME TO LIFE EXPECTANCY CALCULATION");
            System.out.println("1. Complete Registration");
            System.out.println("2. LOGIN");
            System.out.println("3. Exit");
            System.out.println("Copyright Kalisimbi-04");

            int choice = scanner.nextInt();
            scanner.nextLine();

            switch (choice) {
                case 1:
                    completeRegistration();
                    break;
                case 2:
                    login();
                    break;
                case 3:
                    System.exit(0);
                default:
                    System.out.println("Invalid choice. Please try again.");
            }
        }
    }

    private static void completeRegistration() {
        System.out.println("Completing registration...");
        executeBashScript("C:\\Program Files\\Git\\bin\\bash.exe", "-c", "./user-manager.sh complete");
    }

    private static void login() {
        System.out.println("Logging in...");
        executeBashScript("C:\\Program Files\\Git\\bin\\bash.exe", "-c", "./user-manager.sh login");
    }

    private static void executeBashScript(String... command) {
        try {
            ProcessBuilder processBuilder = new ProcessBuilder(command);
            processBuilder.inheritIO();
            Process process = processBuilder.start();
            int exitCode = process.waitFor();
            if (exitCode != 0) {
                System.out.println("Error executing script. Exit code: " + exitCode);
            }
        } catch (IOException | InterruptedException e) {
            e.printStackTrace();
            System.out.println("Error executing script: " + e.getMessage());
        }
    }
}
