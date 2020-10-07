import java.util.ArrayList; 
interface Person{
	public String getName();
	public void setName(String name);
	public ArrayList<String> getPreferences();
	public void setPreferences(ArrayList<String> preferences);
	public boolean isMatched();
	public Person getMatch();
	public void setMatch(Person person);
	public void rejectMatch();
}