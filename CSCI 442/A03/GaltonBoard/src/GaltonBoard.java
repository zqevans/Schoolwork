/*
* Zach Evans
* CSCI 442
* Prof. Granier
* Assignment 3
*/
import java.util.*;

import javax.swing.*;
import javax.swing.Timer;

import java.awt.*;
import java.awt.event.*;


public class GaltonBoard extends JFrame {

	private static GaltonPanel boardPanel = new GaltonPanel();
	private static JTextField tfSlots = new JTextField(4); 
	private static JTextField tfNumBalls = new JTextField(4);
	private static JTextField tfBallRate = new JTextField(4);
	private static JButton startButton = new JButton("Start");
	private static JLabel slotLabel = new JLabel("# of Slots:");
	private static JLabel numBallLabel = new JLabel("# of Balls:");
	private static JLabel ballRateLabel = new JLabel("Ball Rate:");
	private static JPanel inputPanel = new JPanel();
	
	public GaltonBoard(){
		boardPanel = new GaltonPanel();
		setTitle("Galton Board");
		setLayout(new BorderLayout());
		add(boardPanel, BorderLayout.CENTER);
		add(inputPanel, BorderLayout.NORTH);
		inputPanel.add(slotLabel);
		inputPanel.add(tfSlots);
		inputPanel.add(numBallLabel);
		inputPanel.add(tfNumBalls);
		inputPanel.add(ballRateLabel);
		inputPanel.add(tfBallRate);
		inputPanel.add(startButton);
		startButton.addActionListener(new initListener());	
	}
	
	public static void main(String[] args) {
		GaltonBoard frame = new GaltonBoard();
		frame.setSize(800,600);
		frame.setLocationRelativeTo(null);
		frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		boardPanel.setBackground(Color.WHITE);
		frame.setVisible(true);	
	}
	
	class initListener implements ActionListener{
		@Override
		public void actionPerformed(ActionEvent e){
			try{
			int numSlots = Integer.parseInt(tfSlots.getText());
			int numBalls = Integer.parseInt(tfNumBalls.getText());
			int ballRate = Integer.parseInt(tfBallRate.getText());
			boardPanel.initPanel(numSlots, numBalls, ballRate);
			boardPanel.repaint();
			}
			catch(NumberFormatException nfe){
				System.out.println("Bad input");
			}
		}
	}
	
}

class GaltonPanel extends JPanel{ 
	
	private ArrayList<Ball> balls = new ArrayList<Ball>();
	private int[] slotCount;
	private int numBalls;
	private int ballRate;
	private int numSlots;
	private int pegRadius;
	private int ballsSent;
	private int startX= this.getWidth()/2;
	private int startY = 50;
	private int slotY;
	private Timer frameTimer = new Timer(1000/3, new StateChangeListener());
	private GaltonPanel self = this;
	
	public void initPanel(int numSlots, int numBalls, int ballRate){
		
		this.balls.clear();
		this.numSlots = numSlots;
		this.ballRate = ballRate;
		this.numBalls = numBalls;
		this.ballsSent = 0;
		slotCount = new int[numSlots];
		for(int i = 0; i<numSlots; i++){
			slotCount[i] = 0;
		}
		if (frameTimer.isRunning()){
			frameTimer.stop();
		}
		frameTimer.start();
	}
	
	public void addBall(Ball b){
		this.balls.add(b);
	}
	
	class StateChangeListener implements ActionListener{
		public void actionPerformed(ActionEvent e){
			for (Ball b: balls){
				b.nextState();
			}
			if(ballsSent < numBalls){
				int numToSend = Math.min(numBalls-ballsSent, ballRate);
				for (int i = 0; i < numToSend; i++){
					addBall(new Ball());
				}
				ballsSent += numToSend;
			}
			self.repaint();
		}
	}
	
	@Override
	  
	  protected void paintComponent(Graphics g) {
	    super.paintComponent(g);
	    g = (Graphics2D)g;
	   ((GaltonBoard)this.getParent().getParent().getParent().getParent()).setTitle(Integer.toString(this.getWidth())+" x "+Integer.toString(this.getHeight()));
	    pegRadius=Math.min(this.getWidth()/40, this.getHeight()/30);
	    if (numSlots > 0){ //Draw pegs and bottom lines
		    startX = this.getWidth()/2;
		    for (int row = 0; row <= numSlots-1; row++){
				for (int pegX = startX-(row*pegRadius); pegX < startX+(row*pegRadius); pegX+=2*pegRadius){
					int pegY = startY+(pegRadius*2*row);
					if (row == numSlots-1){
						slotY = pegY;
						((Graphics2D)g).setStroke(new BasicStroke(5));
			    		g.setColor(Color.BLACK);
			    		g.drawLine(pegX+pegRadius/2, pegY+pegRadius/2, pegX+pegRadius/2, pegY+4*pegRadius+pegRadius/2);
			    	}
					g.setColor(Color.BLACK);
			    	g.fillOval(pegX, pegY, pegRadius, pegRadius);
			    	g.setColor(Color.GREEN);
			    	g.fillOval(pegX, pegY, pegRadius-2, pegRadius-2);
			    	
			    	
				}
			}
		    slotY += 3*pegRadius;
		    
		    for (int i = 0; i < numSlots; i++){ //Draw slot numbers
		    	if (slotCount[i] > 0){
		    		for (int j = 0; j < Math.min(3,slotCount[i]); j++){
		    			g.setColor(Color.BLACK);
		    			g.fillOval( startX-((numSlots)*pegRadius)+(2*pegRadius*i), slotY-(j*pegRadius), pegRadius, pegRadius);
		    			g.setColor(Color.RED);
		    			g.fillOval( startX-((numSlots)*pegRadius)+(2*pegRadius*i), slotY-(j*pegRadius), pegRadius-2, pegRadius-2);
		    		}
		    	}
		    	g.setColor(Color.BLUE);
		    	g.drawString(Integer.toString(slotCount[i]), startX-((numSlots)*pegRadius)+(2*pegRadius*i)+(pegRadius/4), slotY+((3*pegRadius)/4));
		    }
		    //Draw rest of lines
		    g.setColor(Color.BLACK);
		    g.drawLine(startX-((numSlots+1)*pegRadius)+(pegRadius/2),startY+(pegRadius*2*(numSlots-1))+(pegRadius/2) ,startX-((numSlots+1)*pegRadius)+(pegRadius/2),startY+(pegRadius*2*(numSlots-1))+(pegRadius/2)+4*pegRadius);
		    g.drawLine(startX+((numSlots)*pegRadius)-(pegRadius/2),startY+(pegRadius*2*(numSlots-1))+(pegRadius/2) ,startX+((numSlots)*pegRadius)-(pegRadius/2),startY+(pegRadius*2*(numSlots-1))+(pegRadius/2)+4*pegRadius);
		    g.drawLine(startX-(2*pegRadius), startY-(pegRadius)+(pegRadius/2),startX-((numSlots+1)*pegRadius)+(pegRadius/2),startY+(pegRadius*2*(numSlots-1))+(pegRadius/2) );
		    g.drawLine(startX+pegRadius, startY-(pegRadius)+(pegRadius/2),startX+((numSlots)*pegRadius)-(pegRadius/2),startY+(pegRadius*2*(numSlots-1))+(pegRadius/2));
		    
		    for (Ball b: balls){ //Draw balls
		    	if (!b.inSlot){
		    	g.setColor(Color.BLACK);
		    	g.fillOval(startX-(numSlots*pegRadius)+((b.currentCol-1)*pegRadius) , startY+(pegRadius*b.currentRow), pegRadius, pegRadius);
		    	g.setColor(Color.RED);
		    	g.fillOval(startX-(numSlots*pegRadius)+((b.currentCol-1)*pegRadius)  , startY+(pegRadius*b.currentRow), pegRadius-2, pegRadius-2);
		    	}
		    }
	    } 
	  }
	class Ball{
		
		private int currentRow;
		private int currentSlot;
		private boolean onPeg;
		private boolean inSlot;
		private int currentCol;
		private Random rand = new Random();
		
		public Ball(){
			//this.loc = new Point(startX-pegRadius, startY);
			this.currentCol = numSlots;
			this.currentRow = 0;
			this.onPeg = false;
			this.inSlot = false;
			
			
		}
		public void nextState(){
			if (!this.inSlot){
				if (this.onPeg){ //On a peg
					int direction = rand.nextInt(2);
					if (direction == 0){
						this.currentCol -=1;	
					}
					else{
						this.currentCol += 1;
					}
					this.currentRow++;
					this.onPeg = false;
				}
				else{ //Between pegs
					if (currentRow == (2*numSlots)-2){ //About to hit a slot
						this.inSlot = true;
						this.currentSlot=(currentCol+1)/2;
						this.currentSlot--;
						slotCount[currentSlot] += 1;	
					}
					else{
						this.currentRow++;
					}
					this.onPeg = true;
				}
			}
		}
		
		
	}
}





