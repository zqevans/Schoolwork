/*
 * Author: Zach Evans
 * CSCI 442 Spring 2014
 * Battleship Project
 */
public class Point {
	private char letter;
	private int number;
	/**
	 * <p>The constructor for the point</p>
	 * @param letter The letter coordinate of the point
	 * @param number The number coordinate of the point
	 */
	public Point(char letter, int number){
		this.letter = letter;
		this.number = number;
	}
	
	/**
	 * <p>Getter for the letter coordinate</p>
	 * @return The letter coordinate
	 */
	public char getLetter(){
		return this.letter;
	}
	/**
	 * <p>Getter for the number coordinate</p>
	 * @return The number coordinate of the point
	 */
	public int getNumber(){
		return this.number;
	}
	
	/**
	 * <p>Checks if the points hold the same coordinate</p>
	 * @param p1 The first point to check
	 * @param p2 The second point to check
	 * @return Whether or not the points have the same number and letter coordinates
	 */
	public static boolean samePoint(Point p1, Point p2){
		return (p1.letter == p2.letter && p1.number == p2.number);
	}
}
