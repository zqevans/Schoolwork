package a01;
import java.util.regex.*;
import java.io.*;
public class BusCrossing {
	

	public static void main(String[] args) throws IOException {
		
		BufferedReader inputReader = new BufferedReader(new InputStreamReader(System.in));
		
		int nextID = 1;
		String inputString = inputReader.readLine();
		String[] inputParts = inputString.split(":");
		Pattern delayPattern = Pattern.compile("DELAY[(](\\d+)[)]");
		ControllerThread trafficController = new ControllerThread();
		trafficController.start();
		for(String s : inputParts){
			s = s.trim();
			Matcher strMatch = delayPattern.matcher(s);
			if (s.matches("^\\d+$")){
				int numBusses = Integer.parseInt(s);
				for(int i = 0; i < numBusses; i++){
					BusThread.makeBus(nextID);
					nextID++;
				}
			
			}
			else if(strMatch.matches()){
				int delayTime = Integer.parseInt(strMatch.group(1));
				try {
					Thread.sleep(delayTime*1000);
				} catch (InterruptedException e) {
					e.printStackTrace();
				}
			}
		}
		
		
		
		System.out.println("Done starting busses");

	}

}
