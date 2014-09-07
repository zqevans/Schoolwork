package cs345evansz2;

import java.util.*;

public class VocabItem {
	
	private String vocabName;
	
	private Collection <Word> wordList = new HashSet<Word>();

	VocabItem (String inVocabName, Word...words){
		
		vocabName = inVocabName;
		
		for (Word w : words)
		{
			wordList.add(w);
		}
		
	}
	
	public static VocabItem makeVocab (String inVocabName, Word...words){
		return new VocabItem(inVocabName, words);
	}
	
	public String getName(){
		return vocabName;
	}
	
	public Collection<Word> getWordList(){
		return wordList;
	}
	
}
