//Manlin Guo 6602848
import java.io.FileNotFoundException;  // Import this class to handle errors
import java.util.ArrayList; 


public class StableMatching{
	public static void main(String[] args) {

	    ArrayList<Person> employers;
	    ArrayList<Person> students;
		//default: read employer first, then student
		Helper helper = new Helper();
		try{
			employers = helper.readFile(args[0], true);
		    students = helper.readFile(args[1], false);

		    Boolean finished = false;
		    Boolean flag = false;
		    while(!finished){
		    	flag = false;
		    	for (Person employer : employers){
		    		if (employer.isMatched() == false){
		    			flag = true;
		    			for (String studentName : employer.getPreferences()){
		    				boolean nextStudent = true;
		    				for (Person student : students){
		    					if (student.getName().equals(studentName)){
			    					if (student.isMatched() == false){	
				    					employer.setMatch(student);
				    					student.setMatch(employer);
				    					nextStudent = false;
				    					break;
				    				}
			    				    else if (student.getPreferences().indexOf(employer.getName())
			    				    	< student.getPreferences().indexOf(student.getMatch().getName())){
				    					student.getMatch().rejectMatch();
				    					student.setMatch(employer);
				    					employer.setMatch(student);
				    					nextStudent = false;
				    					break;
				    				}
				    			}	
		    				}
		    				if(nextStudent == false)
		    				break;	
		    			}
		    		}
		    	}
		    	if (flag == false) finished = true;
		    }
			helper.writeFile(employers, students);

		}
		catch(FileNotFoundException e){
			System.out.println("Couldn't read file. System will now exit.");
			System.exit(-1);
		}
		catch(Exception e){
			System.out.println("Something goes wrong...");
			System.exit(-1);
		}
	}
}