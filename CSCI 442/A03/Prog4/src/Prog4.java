import javax.swing.*;

import java.sql.*;

public class Prog4 extends JFrame{

	public Prog4(){
		
	}
	
	
	public static void main (String[] args){
		DriverManager.registerDriver(new Driver());
		Prog4 frame = new Prog4();
		frame.setSize(800,600);
		frame.setLocationRelativeTo(null);
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		frame.setVisible(true);	
		Object[] possibilities = {"ham", "spam", "yam"};
		String s = (String)JOptionPane.showInputDialog(
                frame,
                "Complete the sentence:\n"
                + "\"Green eggs and...\"",
                "Customized Dialog",
                JOptionPane.PLAIN_MESSAGE
               );
		
	}
}
