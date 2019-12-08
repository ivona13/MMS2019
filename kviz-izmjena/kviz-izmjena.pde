import java.util.ArrayList;
import java.util.List;
import java.util.Map;

Map<String, ArrayList<String> > map = new HashMap<String, ArrayList<String> >();
Map<String, String> correctAnswers = new HashMap<String, String>();

final int qState = 0;
int status = qState;
final int end = 1;
final int answered = 2;
int time = millis();
int wait = 1500;
int randInt;
int numberOfCorrect = 0;
final int numberOfQuestions = 10;
final int totalNumberOfQuestions = map.size();
int indexOfQuestion = (int)random(0, totalNumberOfQuestions);
int answerIndex;
int numberOfAsked = 1;
boolean correct = false;
int waiting = 2*1000;
int questionApperance = 4*1000;
boolean newQuestion = false;
int questionStart = millis();
long mil = millis();
long s = 0, min = 0;

String question(Map<String, ArrayList<String> > map, int number){
  int i = 0;
  for (Map.Entry e : map.entrySet()){
    if(i == number) {
      return e.getKey().toString();
    }
    i++;
  }
  return "";
}

  
void display(Map<String, ArrayList<String> > map, int number){
  fill(0,102,150);
  textSize(16);
  String question = question(map, number);
  text(question, 30, 30);
  ArrayList<String> array = map.get(question);
  for(int j = 0; j < array.size(); j++) {
    text((j+1) + ".) " + array.get(j), 30, 30+25*(j+1));
  }
}

boolean check(char keyToTest, Map<String, String> correctAnswers, Map<String, ArrayList<String> >map, int number) {
  int answer = parseInt(correctAnswers.get(question(map, number)));  
  int key = keyToTest - '0';
  if(answer == key) { print("Točno"); return true; }
  return false;
}

void setup(){
  size(800,800);
  background(0, 0, 0);
  
  Table table = loadTable("data.csv", "header");
  int numOfRows = table.getRowCount();
  
  for(int i = 0; i < numOfRows; i++) {
    TableRow row = table.getRow(i);
    ArrayList<String> answers = new ArrayList<String>();
    answers.add(row.getString("odg1"));
    answers.add(row.getString("odg2"));
    answers.add(row.getString("odg3"));
    answers.add(row.getString("odg4"));
    map.put(row.getString("pitanje"), answers);
    correctAnswers.put(row.getString("pitanje"), row.getString("tocanOdg"));
  }
  
  answerIndex = int(correctAnswers.get(question(map, indexOfQuestion)));
}  

void draw(){
  background(0, 0, 0);
  mil = millis();

  if(mil >= 1000) {
    s = mil /1000;
    mil -= s*1000;
  }
  if(s >= 60) {
    min = s/60;
    s-= min * 60;
  }
  
  if(numberOfAsked > numberOfQuestions) { numberOfAsked--; status = end; }
  
  fill(204, 255, 0);
  textSize(16);
  text("Proteklo vrijeme: " + min + " minuta, "+ s + " sekundi, " 
    + mil + " milisekundi.", 200, 200);
  text("Točni odgovori: " + numberOfCorrect + "/" + numberOfAsked, 300, 300);
  
  switch(status) {
    case qState:
      display(map, indexOfQuestion);
      if(newQuestion) { numberOfAsked++; newQuestion = false; }
      
      fill(255, 204, 0);
      text("Preostalo vrijeme za odgovor: " + (4 + (questionStart - millis()) / 1000), 500, 500);
      if((millis() - questionStart) >= questionApperance) {
          indexOfQuestion = (int)random(0, totalNumberOfQuestions);
          questionStart = millis();
          numberOfAsked++;
      }
      break;
      case answered:
        display(map, indexOfQuestion);
        if(correct) writeMessage(answerIndex, "Točan odgovor!");
        else writeMessage(answerIndex, "Vaš odgovor je netočan! Ovo je točan odgovor!");
        if(millis() - time > waiting) {
          indexOfQuestion = (int)random(0, totalNumberOfQuestions);
          status = qState;
          time = millis();
          answerIndex = int(correctAnswers.get(question(map, indexOfQuestion)));
          correct = false;
          newQuestion = true;
          questionStart = millis();
        }
        break;    
     case end:
       correct = false;
       text("KRAJ KVIZA! Za ponovnu igru pritisnite 'r' ", 100, 100);
       double percent = (double)numberOfCorrect / numberOfAsked;
       text("Uspjeh na ovom kvizu: " + percent*100 + "%.", 100, 150);
       break;
   }   
}

void keyPressed() {
  
    if(key == 'r' && status == end) {
      numberOfCorrect = 0;
      numberOfAsked = 0;
      status = qState;
      newQuestion = true;
      questionStart = millis();
      return;
    }
    
    if(check(key, correctAnswers, map, indexOfQuestion)) {
        writeMessage(answerIndex, "Točan odgovor!");
        numberOfCorrect++;
        correct = true;
        newQuestion = true;
      }
     status = answered;
     time = millis();
}

void writeMessage(int answerIndex, String message){
  fill(39, 185, 208);
  textSize(16);
  text(message, 150, 30+25*(answerIndex));
}
