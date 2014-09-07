/*
 * Zach Evans
 * CSCI 442
 * Spring 2014
 * Assignment 5
 * 
 * This program searches through an XML file containing class data for 
 * WWU classes and finds time conflicts, printing out relevant information.
 */

import org.jdom2.input.SAXBuilder;
import org.jdom2.input.sax.XMLReaders;
import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.JDOMException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.io.*;
import java.util.*;



public class ClassConflicts {
	/**
	 * This is the main class for the program.
	 */
	private static SAXBuilder builder = new SAXBuilder();
	private static File coursesFile = new File("WWU_courses.xml");
	private static Hashtable<String, ArrayList<Element>> coursesByRoom = new Hashtable<String, ArrayList<Element>>();
	private static Hashtable<String, ArrayList<Element>> coursesByProf = new Hashtable<String, ArrayList<Element>>();
	public static void main(String[] args) {
		try {
			builder.setXMLReaderFactory(XMLReaders.DTDVALIDATING);
			Document courseDOM = (Document)builder.build(coursesFile);
			Element rootNode = courseDOM.getRootElement();
			
			
			for (Element course: rootNode.getChildren("course")){
				for (Element section: course.getChildren("section")){
					String sectionRoom = section.getAttributeValue("room");
					String sectionProf = section.getAttributeValue("prof");
					if(coursesByRoom.containsKey(sectionRoom)){
						coursesByRoom.get(sectionRoom).add(section);
					}
					else{
						ArrayList<Element> newRoomArray = new ArrayList<Element>();
						newRoomArray.add(section);
						coursesByRoom.put(sectionRoom, newRoomArray);
					}
					
					if (coursesByProf.containsKey(sectionProf)){
						coursesByProf.get(sectionProf).add(section);
					}
					else{
						ArrayList<Element> newProfArray = new ArrayList<Element>();
						newProfArray.add(section);
						coursesByProf.put(sectionProf, newProfArray);
					}
				}
			}
			for (String room : coursesByRoom.keySet()){ //Check for room conflicts
				ArrayList<Element> sectionList = coursesByRoom.get(room);
				SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm a");
				Collections.sort(sectionList, new sectionTimeComparator(timeFormat));
				Element lastSection = null;
				for (Element section: sectionList){
					if (lastSection == null){ //First section in the list
						lastSection = section;
					}
					else{
						try {
							Date currentStart = timeFormat.parse(section.getAttributeValue("startTime"));
							Date lastEnd = timeFormat.parse(lastSection.getAttributeValue("endTime"));
							if (currentStart.getTime() - lastEnd.getTime() < 900000L){ //Difference in time less than 15 minutes
								System.out.println(String.format("Room Conflict:\nRoom: %s \n%s (%s): %s - %s\n%s (%s): %s - %s", 
										section.getAttributeValue("room"),
										((Element) lastSection.getParent()).getAttributeValue("num"),
										lastSection.getAttributeValue("crn"),
										lastSection.getAttributeValue("startTime"),
										lastSection.getAttributeValue("endTime"),
										((Element) section.getParent()).getAttributeValue("num"),
										section.getAttributeValue("crn"),
										section.getAttributeValue("startTime"),
										section.getAttributeValue("endTime")
										));
								System.out.println();
							}
							lastSection = section;
						} catch (ParseException e) {
							System.out.println(e.getMessage());
						}
					}
				}
			}
			
			for (String prof: coursesByProf.keySet()){ //Loop through professors
			
				ArrayList<Element> profCourses = coursesByProf.get(prof);
				SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm a");
				Collections.sort(profCourses, new sectionTimeComparator(timeFormat));
				Element lastSection = null;
				for (Element section: profCourses){
					if (lastSection == null){ //First section in the list
						lastSection = section;
					}
					else{
						try {
							Date currentStart = timeFormat.parse(section.getAttributeValue("startTime"));
							Date lastEnd = timeFormat.parse(lastSection.getAttributeValue("endTime"));
							if (currentStart.getTime() - lastEnd.getTime() < 900000L){ //Difference in time less than 15 minutes
								System.out.println(String.format("Professor Conflict:\nProfessor: %s \n%s (%s): %s - %s\n%s (%s): %s - %s", 
										section.getAttributeValue("prof"),
										((Element) lastSection.getParent()).getAttributeValue("num"),
										lastSection.getAttributeValue("crn"),
										lastSection.getAttributeValue("startTime"),
										lastSection.getAttributeValue("endTime"),
										((Element) section.getParent()).getAttributeValue("num"),
										section.getAttributeValue("crn"),
										section.getAttributeValue("startTime"),
										section.getAttributeValue("endTime")
										));
								System.out.println();
								
							}
							lastSection = section;
						} catch (ParseException e) {
							System.out.println(e.getMessage());
						}
					}
				}
				
			}
			
		} catch (JDOMException e) {
			System.out.println(e.getMessage());
		} catch (IOException e) {
			System.out.println(e.getMessage());
		} 

	}
	

}
class sectionTimeComparator implements Comparator<Element>{
	/**
	 * This is a custom comparator so I can sort the sections by time.
	 * 
	 */
	SimpleDateFormat timeFormat = null;
	public sectionTimeComparator(SimpleDateFormat tf){
		/**
		 * @param tf This is a SimpleDateFormat object that gives the format of the start time in the sections
		 */
		this.timeFormat = tf;
	}
	@Override
	public int compare(Element section1, Element section2){
		/**
		 * @param section1 The first section you wish to compare
		 * @param section2 The second section you wish to compare
		 */
		Date section1Date = null;
		Date section2Date = null;
		try {
			section1Date = timeFormat.parse(section1.getAttributeValue("startTime"));
			section2Date = timeFormat.parse(section2.getAttributeValue("startTime"));
		} catch (ParseException e) {
			System.out.println(e.getMessage());
		}
		return section1Date.compareTo(section2Date);	
	}
}
