/*
 * Author: Zach Evans
 * CSCI 442 Spring 2014
 * Battleship Project
 */
public class BSUtil {
	/**
	 * <p>This turns a number into its character in the alphabet
	 * @param num Number to make into a character
	 * @return The capital letter in the alphabet corresponding to the integer
	 */
	public static char numToChar(int num){
		return (char)(num-(int)'A' - 1);
	}
	
	/**
	 * <p>This returns the index of a character in the alphabet</p>
	 * @param inChar The character to find the index of
	 * @return The index of the character
	 */
	public static int charToInt(char inChar){
		return ((int)inChar)-(int)'A' + 1;
	}
}
