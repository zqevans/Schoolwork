/*
 * Zach Evans
 * CSCI 442
 * Assignment 4
 * Country Data
 * This program presents data about countries and allows for the input of new data
 */

import javax.imageio.*;
import javax.swing.*;

import java.io.*;
import java.util.*;
import java.awt.*;
import java.awt.event.*;
import java.io.IOException;
import java.sql.*;


/**
 * Class for the entire program
 * @author Zach Evans
 * @version 1.0
 */
public class CountryData extends JFrame{

	/**
	 * 
	 */
	private static final long serialVersionUID = 7989576122551611105L;
	static JComboBox countryList;
	Connection dbReader = null;
	Connection dbWriter = null;
	ResultSet countryResult;
	Statement sqlStatement;
	ArrayList<String> countries = new ArrayList<String>();
	InfoPanel mainPanel = new InfoPanel();
	
	/**
	 * This is the constructor for the main frame
	 */
	public CountryData() {
		try {
		    Class.forName("com.mysql.jdbc.Driver");
		} catch (ClassNotFoundException e) {
		    throw new RuntimeException("Cannot find the driver in the classpath!", e);
		}
		try{
		dbReader = DriverManager.getConnection("jdbc:mysql://db.cs.wwu.edu:3306/evansz2_CS442", "evansz2_reader", "EwtRd6B2J");
		dbWriter = DriverManager.getConnection("jdbc:mysql://db.cs.wwu.edu:3306/evansz2_CS442", "evansz2_writer", "ZmTWK4ApN");
		}
		catch(SQLException e){
		System.out.println("Couldn't connect to database.");	
		}
		try {
		sqlStatement = dbReader.createStatement();
		countryResult = sqlStatement.executeQuery("SELECT country, flag FROM flags");
		}
		catch(SQLException e){
			System.out.println("Couldn't execute query");
		}
		try {
			while(countryResult.next()){
				countries.add(countryResult.getString("country"));
			}
		} catch (SQLException e) {
			System.out.println("Error on adding countries");
		}
		countryList = new JComboBox();
		countryList.addItem("Select a Country");
		for (String country: countries){
			countryList.addItem(country);
		}
		countryList.addItem("New Entry");
		countryList.addActionListener(new countryBoxListener());
		setLayout(new BorderLayout());
		add(countryList, BorderLayout.NORTH);
		add(mainPanel, BorderLayout.CENTER);
	}
	
	public static void main (String[] args){
		
		
		CountryData frame = null;
		
		frame = new CountryData();
		frame.setSize(800,600);
		frame.setLocationRelativeTo(null);
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		frame.setVisible(true);	
	}
	/**
	 * This is the listener for the user selecting a new country from the ComboBox.
	 * @author Zach Evans
	 *
	 */
	class countryBoxListener implements ActionListener{
		public void actionPerformed(ActionEvent e){
			String countryName = (String)((JComboBox)e.getSource()).getSelectedItem();
			try {
				if (countryName == "New Entry"){
					mainPanel.addCountryInfo();
				}
				else if (countryName != "Select a Country"){
					mainPanel.updatePanel(countryName);
				}
			} catch (SQLException e1) {
				System.out.println("Couldn't update panel: "+e1.getMessage());
			}
		}
	}
	
	/**
	 * Panel that holds the information about the country
	 * @author zqevans
	 *
	 */
	class InfoPanel extends JPanel{
		
		/**
		 * 
		 */
		private static final long serialVersionUID = 2662739657022893173L;
		//Panels for box layout
		JPanel namePanel = new JPanel();
		JPanel capitalPanel = new JPanel();
		JPanel languagePanel = new JPanel();
		JPanel flagPanel = new JPanel();
		
		//Dynamic labels
		JLabel countryName = new JLabel(); //Label for the country name
		JLabel countryFlag = new JLabel(); //Label to hold the flag
		JLabel countryCapitals = new JLabel(); //Label to hold the capitals
		JLabel countryLanguages = new JLabel(); //Label to hold the languages
		
		//Static labels
		JLabel nameLabel = new JLabel("Country:");
		JLabel lblFlag = new JLabel("Flag:");
		JLabel lblCapitals = new JLabel("Capital:");
		JLabel lblLanguages = new JLabel("Languages:");
		
		ResultSet countryInfo; //ResultSet for information for the country
		String filePath = "";
		
		/**
		 * Constructor for the panel holding the information
		 * @author Zach Evans
		 */
		public InfoPanel(){
			setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
			
			
			namePanel.add(nameLabel);
			namePanel.add(countryName);
			add(namePanel);
			
			flagPanel.add(lblFlag);
			flagPanel.add(countryFlag);
			add(flagPanel);
			
			capitalPanel.add(lblCapitals);
			
			capitalPanel.add(countryCapitals);
			add(capitalPanel);
			
			languagePanel.add(lblLanguages);
			languagePanel.add(countryLanguages);
			add(languagePanel);
			
			
		}
		
		/**
		 * This function gets information for a new country and adds it to the list
		 * @throws SQLException
		 */
		public void addCountryInfo() throws SQLException{
			
			//Input panels
			final JPanel namePanel = new JPanel();
			final JPanel capitalPanel = new JPanel();
			final JPanel languagePanel = new JPanel();
			final JPanel flagPanel = new JPanel();
			
			//Input boxes
			final JTextField nameInput = new JTextField(10);
			final JTextField capitalsInput = new JTextField(10);
			final JTextField languagesInput = new JTextField(10);
			
			//Flag image chooser, button, and stream
			final JFileChooser imgInput = new JFileChooser();
			final JButton imgOpen = new JButton("Select Flag Image...");
			final InputStream flagStream;
			
			//Input labels
			final JLabel nameLabel = new JLabel("Enter country name:");
			final JLabel capitalLabel = new JLabel("Enter capitals separated by commas");
			final JLabel languageLabel = new JLabel("Enter languages separated by commas");
			final JLabel fileLabel = new JLabel("Please select a file");
			
			//Input Pop-up
			final JPanel inputDialogPanel = new JPanel();
			
			//SQL statements
			PreparedStatement flagInsert = dbWriter.prepareStatement("INSERT INTO flags(country, flag) VALUES(?,?)");
			PreparedStatement languageInsert = dbWriter.prepareStatement("INSERT INTO languages(country, language) VALUES(?,?)");
			PreparedStatement capitalInsert = dbWriter.prepareStatement("INSERT INTO capitals(country, capital) VALUES(?,?)");
			
			
			inputDialogPanel.setLayout(new BoxLayout(inputDialogPanel, BoxLayout.Y_AXIS));
			
			namePanel.add(nameLabel);
			namePanel.add(nameInput);
			inputDialogPanel.add(namePanel);
			
			capitalPanel.add(capitalLabel);
			capitalPanel.add(capitalsInput);
			inputDialogPanel.add(capitalPanel);
			
			languagePanel.add(languageLabel);
			languagePanel.add(languagesInput);
			inputDialogPanel.add(languagePanel);
			
			flagPanel.add(imgOpen);
			flagPanel.add(fileLabel);
			inputDialogPanel.add(flagPanel);
			
			imgOpen.addActionListener(new ActionListener(){
				public void actionPerformed(ActionEvent e){
					int returnVal = imgInput.showOpenDialog(inputDialogPanel);
					if (returnVal == JFileChooser.APPROVE_OPTION){
						filePath = imgInput.getSelectedFile().getAbsolutePath();
						fileLabel.setText(filePath.substring(filePath.lastIndexOf('/')+1));
					}
				}
			});
		
			int result = JOptionPane.showConfirmDialog(null, inputDialogPanel, "Please enter country data: ", JOptionPane.OK_CANCEL_OPTION);
			boolean valid = (nameInput.getText().length() > 0 && languagesInput.getText().length() > 0 && capitalsInput.getText().length() > 0 && filePath != "");
			
			if (result == JOptionPane.YES_OPTION  && valid){
				String country = nameInput.getText();
				String[] languageArray = languagesInput.getText().split(",");
				String[] capitalArray = capitalsInput.getText().split(",");
				languageInsert.setString(1, country);
				flagInsert.setString(1, country);
				capitalInsert.setString(1, country);
				try {
					flagStream = new FileInputStream(new File(filePath));
					flagInsert.setBinaryStream(2, flagStream);
					flagInsert.executeUpdate();
				} catch (FileNotFoundException e1) {
					System.out.println("Couldn't open file: "+filePath);
				}
				
				for (String language: languageArray){
					languageInsert.setString(2, language.trim());
					languageInsert.executeUpdate();
				}
				for (String capital: capitalArray){
					capitalInsert.setString(2,  capital.trim());
					capitalInsert.executeUpdate();
				}
				countries.add(country);
				Collections.sort(countries);
				countryList.removeAllItems();
				countryList.addItem("Select a Country");
				for (String s: countries){
					countryList.addItem(s);
				}
				countryList.addItem("New Entry");
			}
		}
		
		
		/**
		 * Updates the InfoPanel to show information about a particular country.
		 * @param country A string holding the country you would like to view
		 * @throws SQLException
		 */
		public void updatePanel(String country) throws SQLException{
			countryName.setText(country);
			try {
				countryInfo = sqlStatement.executeQuery("SELECT flags.country, flag, capital, "+
						"GROUP_CONCAT(DISTINCT capitals.capital SEPARATOR ', ') AS capitalList, "+
						"GROUP_CONCAT(DISTINCT languages.language SEPARATOR ', ') AS languageList "+
						"FROM flags, capitals, languages "+
						"WHERE flags.country = capitals.country AND flags.country = languages.country "+
						"AND flags.country = '" + country +
						"' GROUP BY flags.country");
			} catch (SQLException e) {
				System.out.println("Couldn't execute query: "+e.getMessage());
				return;
			}
			
			countryInfo.next();
			Image flagImage = null;
			try {
				flagImage = ImageIO.read(countryInfo.getBlob("flag").getBinaryStream());
			} catch (IOException e) {
				System.out.println("Couldn't display image");
			}
			ImageIcon flagIcon = new ImageIcon(flagImage.getScaledInstance(-1, 250, 0));
			countryFlag.setIcon(flagIcon);
			countryCapitals.setText(countryInfo.getString("capitalList"));
			countryLanguages.setText(countryInfo.getString("languageList"));
			
			
		}
		
	}
}



