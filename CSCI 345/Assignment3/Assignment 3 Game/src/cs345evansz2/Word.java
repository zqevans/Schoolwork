package cs345evansz2;


public class Word {
	
	private String word;
	private MatchType wordType;

	Word(String inWordString, MatchType inWordType) {
		
		word = inWordString;
		wordType = inWordType;
		
	}
	
	public static Word makeWord (String inWordString, MatchType inWordType){
		
		Word tempWord = new Word(inWordString, inWordType);
		GameGlobals.allWords.add(tempWord);
		
		return tempWord;
	
	}
	

	public String getWord(){
		return word;
	}
	
	public MatchType getType(){
		return wordType;
	}
}