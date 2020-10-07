//Manlin Guo 6602848
import java.util.ArrayList; 

public class Student implements Person{
	String name;
	ArrayList<String> preferences;
	Boolean isMatched;
	Person matchResult;

	public Student(){
		isMatched = false;
		matchResult = null;
	}

	public String getName(){
		return name;
	}

	public void setName(String name){
		this.name = name;

	}
	public ArrayList<String> getPreferences(){
		return preferences;
	}

	public void setPreferences(ArrayList<String> preferences){
		this.preferences = preferences;
	}

	public boolean isMatched(){
		return isMatched;
	}

	public Person getMatch(){
		return matchResult;
	}

	public void setMatch(Person employer){
		this.isMatched = true;
		this.matchResult = employer;
	}

	public void rejectMatch(){
		this.isMatched = false;
		this.matchResult = null;
	}

}