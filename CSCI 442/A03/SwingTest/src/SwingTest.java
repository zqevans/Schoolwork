import javax.swing.*;
import java.awt.*;
import javax.swing.event.*;


public class SwingTest extends JFrame{
	static drawPanel myPanel;
	public SwingTest(){
		this.myPanel = new drawPanel();
		setContentPane(myPanel);
	}
	
	
	public static void main(String[] args) {
		SwingTest myFrame = new SwingTest();
		myPanel.setX(100);
		myFrame.repaint();
		myFrame.setDefaultCloseOperation(EXIT_ON_CLOSE);
		myFrame.setSize(400,400);
		myFrame.setVisible(true);
	}

	class drawPanel extends JPanel{
		
		private int x;
		
		public void setX(int x){
			this.x = x;
		}
		
		public drawPanel(){
			this.x = 5;
		}
		@Override
		public void paintComponent(Graphics g){
			super.paintComponent(g);
			g.fillOval(this.x,10,10,10);
		}
	}
	
}


