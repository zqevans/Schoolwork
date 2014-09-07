package lc;

import java.io.*;
import java.net.*;
 
public class ClientMain {
    public static void main(String[] args) throws IOException {
         
        if (args.length != 1) {
            System.err.println(
                "Usage: java ClientMain <port number>");
            System.exit(1);
        }
 
      
        int portNumber = Integer.parseInt(args[0]);
 
        try{
            Socket echoSocket = new Socket("localhost", portNumber);
            PrintWriter out =
                new PrintWriter(echoSocket.getOutputStream(), true);
            BufferedReader in =
                new BufferedReader(
                    new InputStreamReader(echoSocket.getInputStream()));
            BufferedReader stdIn =
                new BufferedReader(
                    new InputStreamReader(System.in));
            System.out.print("Enter name: ");
            String name = stdIn.readLine();
            System.out.print("Enter number of years: ");
    		int years = Integer.parseInt(stdIn.readLine());
    		System.out.print("Enter loan amount: ");
    		double amt = Double.parseDouble(stdIn.readLine());
    		System.out.print("Enter rate: ");
    		double intRate = Double.parseDouble(stdIn.readLine());
            out.println(name+";"+years+";"+amt+";"+intRate);
            String inLine;
            while((inLine = in.readLine())!= null){
            	System.out.println(inLine);
            }
            
        }catch (IOException e) {
            System.err.println("Couldn't connect to host");
            System.exit(1);
        } 
    }
}
