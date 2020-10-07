//Manlin Guo 6602848
import java.io.File;  
import java.io.FileNotFoundException; 
import java.util.ArrayList; 
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.BufferedReader;
import java.io.BufferedWriter;


public class Helper{
	int sizeOfEmployer; 
	int sizeOfStudent; 

	public ArrayList<Person> readFile(String fileName, Boolean isEmployer) throws FileNotFoundException, IOException{
		ArrayList<Person> data = new ArrayList<>();
		BufferedReader br = new BufferedReader(new FileReader(fileName));
		String line = br.readLine();
		
		while (line != null){
			if(line.length() == 0){
				line = br.readLine();
				continue;
			}
			String[] dataLine = line.split(",");
			Person person;
			if (isEmployer) {
				person = new Employer();}
			else{ 
				person = new Student();}
			ArrayList<String> preferences = new ArrayList<>();
			for (String elem : dataLine){
				preferences.add(elem);
			}
			person.setName(preferences.get(0));
			preferences.remove(0);
			person.setPreferences(preferences);
			data.add(person);
			line = br.readLine();
		}
		br.close();
		return data;
	}

	public void writeFile(ArrayList<Person> employers, ArrayList<Person> students) throws IOException{
		sizeOfEmployer = employers.size();
		sizeOfStudent = students.size();
		String filename = "matches_java_" +sizeOfEmployer + "x" + sizeOfStudent + ".csv";
		File file = new File(filename);
		if (!file.exists()){
			file.createNewFile();
		}
		BufferedWriter writer = new BufferedWriter(new FileWriter(file));
		for (Person employer : employers){
			writer.write(employer.getName() + "," + employer.getMatch().getName());
			writer.newLine();
		}
		writer.flush();
		writer.close();

	}
}