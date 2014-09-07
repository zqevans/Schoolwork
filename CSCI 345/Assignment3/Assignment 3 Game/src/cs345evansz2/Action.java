package cs345evansz2;

public class Action {
	
	
	private VocabItem vocab1;
	private VocabItem vocab2;
	
	
	Action(VocabItem item1, VocabItem item2){
		vocab1 = item1;
		vocab2 = item2;
	}

	
	public void doAction(Word inWord){
		doAction(inWord, null);
	}
	
	public void doAction(Word word1, Word word2){
		/* */
	}
	
	public VocabItem getVocabOne(){
		return vocab1;
	}
	
	public VocabItem getVocabTwo(){
		return vocab2;
	}
	
}
