/*
 * Author: Zach Evans
 * CSCI 442 Spring 2014
 * Battleship Project
 */
import javax.swing.*;
import java.util.*;
import java.awt.*;

@SuppressWarnings("serial")
public class LoginWindow extends JPanel {
	private ArrayList<JTextField> textBoxes = new ArrayList<JTextField>();
	private JLabel titleLabel = new JLabel("Enter Name:");
	private JTextField tfName = new JTextField();
	private JLabel lblServer = new JLabel("Server: ");
	private JTextField tfServer = new JTextField("localhost");
	private JLabel lblPort = new JLabel("Port: ");
	private JTextField tfPort = new JTextField("44200");
	private JTextField len5name = new JTextField("Aircraft Carrier");
	private JTextField len4name = new JTextField("Battleship");
	private JTextField len3name1 = new JTextField("Destroyer");
	private JTextField len3name2 = new JTextField("Submarine");
	private JTextField len2name = new JTextField("Patrol Boat");
	private JLabel lblLen = new JLabel("Length");
	private JLabel lblName = new JLabel("Name");
	private JLabel lblLen5 = new JLabel("5 Squares");
	private JLabel lblLen4 = new JLabel("4 Squares");
	private JLabel lblLen3one = new JLabel("3 Squares");
	private JLabel lblLen3two = new JLabel("3 Squares");
	private JLabel lblLen2 = new JLabel("2 Squares");
	/**
	 * <p>Constructor for the login window </p>
	 */
	public LoginWindow(){
		setLayout(new GridLayout(0, 2, 20,30));
		add(titleLabel);
		add(tfName);
		textBoxes.add(tfName);
		add(lblServer);
		add(tfServer);
		add(lblPort);
		add(tfPort);
		add(lblLen);
		add(lblName);
		add(lblLen5);
		add(len5name);
		textBoxes.add(len5name);
		add(lblLen4);
		add(len4name);
		textBoxes.add(len4name);
		add(lblLen3one);
		add(len3name1);
		textBoxes.add(len3name1);
		add(lblLen3two);
		add(len3name2);
		textBoxes.add(len3name2);
		add(lblLen2);
		add(len2name);
		textBoxes.add(len2name);
	}
	
	/**
	 * <p>Getter for the player name</p>
	 */
	public String getName(){
		return tfName.getText();
	}
	
	/**
	 * <p>Validator function for the login window</p>
	 * @return Whether or not the login window has proper information entered
	 */
	public boolean validLogin(){
		boolean valid = true;
		for (JTextField box: textBoxes){
			if (box.getText().length() == 0){
				valid = false;
			}
		}
		return valid;
	}
	
	/**
	 * <p>Getter for the server name</p>
	 * @return The name of the server
	 */
	public String getServer(){
		return tfServer.getText();
	}
	
	/**
	 * <p>Getter for the port</p>
	 * @return The port as an integer
	 */
	public int getPort(){
		return Integer.parseInt(tfPort.getText());
	}
	
	/**
	 * Returns the names of the ships entered
	 * @return An array holding the five names of the ships
	 */
	public String[] getShips(){
		String[] shipArray = new String[5];
		shipArray[0] = len5name.getText();
		shipArray[1] = len4name.getText();
		shipArray[2] = len3name1.getText();
		shipArray[3] = len3name2.getText();
		shipArray[4] = len2name.getText();
		return shipArray;
	}
	
}
