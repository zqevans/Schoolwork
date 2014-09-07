package cs345evansz2;


public class Path {
	
	private String pathName;
	private VocabItem pathVocab;
	private Room sourceRoom, destRoom;
	
	

	Path(String inName, VocabItem inVocab, Room inSource, Room inDest){
		pathName = inName;
		pathVocab = inVocab;
		sourceRoom = inSource;
		destRoom = inDest;
		
		
	}
	
	public static Path makePath(String inName, VocabItem inVocab, Room inSource, Room inDest){
		
		Path tempPath = new Path(inName, inVocab, inSource, inDest);
		
		inSource.addPath(tempPath);
		GameGlobals.allPaths.add(tempPath);
		
		
		return tempPath;
	}
	
	public String getPathName(){
		return pathName;
	}
	
	public VocabItem getPathVocab(){
		return pathVocab;
	}
	
	public Room getSourceRoom(){
		return sourceRoom;
	}
	
	public Room getDestRoom(){
		return destRoom;
	}
	
	

	
	
	
}
