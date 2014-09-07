package cs345evansz2;

import java.io.*;
import java.util.*;


public class CommandInterp {
	
	private BufferedReader reader;
	private PrintStream stream;
	private boolean exit = false;
	private String readString;
	private List <String> wordList = new LinkedList<String>();
	private List <Word> validWords = new LinkedList<Word>();

	CommandInterp(BufferedReader inReader, PrintStream inStream){
		
		GameGlobals.messageOut = inStream;
		reader = inReader;
		stream = inStream;
		exit = false;
		
	}
	
	public void setExit(boolean exitBool){
		exit = exitBool;
	}
	
	public void run(){
		while (!exit){
			try {
				readString = reader.readLine();
			} catch (IOException e) {
				stream.print("Input error");
				continue;
			}
					
			wordList = GameUtil.canonicalCommand(readString);	
			validWords.removeAll(validWords);
			
			if (wordList.size() == 2 || wordList.size() == 1){ // 1 or 2 arguments
				
				for (String s : wordList){
					int numMatches = 0;
					Word tempWord = new Word("", MatchType.NONE);
					numMatches = 0;
					for (Word w: GameGlobals.allWords){
						if ((GameUtil.isPrefixMatch(s, w) && w.getType() == MatchType.PREFIX) 
								||( s.equals(w.getWord()) && w.getType() == MatchType.EXACT)){
							numMatches++;
							tempWord = w;
						}
					}
					if (numMatches == 1){ //Only one word matched
						validWords.add(tempWord); //Add to validWords
					}
					else if(numMatches > 1){
						stream.printf("Too many matches for \"%s\".", s);
					}
				}
				if (validWords.size() == wordList.size()){ //All words are valid
					
						for (Action a: GameGlobals.allActions){
							for (Word w: a.getVocabOne().getWordList()){
								if (w == validWords.get(0)){
									
									if (validWords.size() == 1){
										
										a.doAction(validWords.get(0));
									}
									else if (validWords.size() == 2){
										
										a.doAction(validWords.get(0), validWords.get(1));
									}
								}
							}			
						}			
				}
				else{
					stream.println("Not a valid input.");
					continue;
				}
				
			}
			else if (wordList.size() > 2){ // Too many arguments
				stream.println("Too many words.");
				
				continue;
			}			
		}
	}
}
