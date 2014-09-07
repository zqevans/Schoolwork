import java.net.*;
import java.io.*;

public class ServerMain {
    public static void main(String[] args) throws IOException {

        if (args.length > 1) {
            System.err.println("Usage: java EchoServer [port number]");
            System.exit(1);
        }

	int portNumber;

	if (args.length == 1){
        	portNumber = Integer.parseInt(args[0]);
	}
	else{
		portNumber = 44200;
	}

        try {
            ServerSocket serverSocket =
                new ServerSocket(portNumber);
            System.out.println("Starting server...");
            Socket clientSocket = serverSocket.accept();
            PrintWriter out =
                new PrintWriter(clientSocket.getOutputStream(), true);
            BufferedReader in = new BufferedReader(
                new InputStreamReader(clientSocket.getInputStream()));

            String inputLine;

            while ((inputLine = in.readLine()) != null) {
            	String[] inputParts = inputLine.split(";");
            	String name = inputParts[0];
            	int years = Integer.parseInt(inputParts[1]);
            	double amt = Double.parseDouble(inputParts[2]);
            	double apr = Double.parseDouble(inputParts[3]);
            	double rate = apr/1200;
            	double monthly = (rate+(rate/((Math.pow(1+rate, years*12))-1)) )*amt;
            	String letterString = String.format("Dear %s, \n"+
            	"Your loan request of $%.2f for %d years at %.2f%% annual interest rate has been approved.\n"+
            			"It will cost you $%.2f every month.\nThank you.",name, amt, years, apr, monthly );


            	System.out.print(String.format("Account: %s\nMonthly Payment: $%.2f\n",name, monthly));
            	out.println(letterString);
            }
        } catch (IOException e) {
            System.out.println("Exception caught when trying to listen on port "
                + portNumber + " or listening for a connection");
            System.out.println(e.getMessage());
        }
    }
}
