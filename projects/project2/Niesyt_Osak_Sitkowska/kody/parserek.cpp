#include <fstream>
#include <string>
#include <iostream>
using namespace std;

string stripTags(string text) {
    string result = "";
    bool inTag = false;
    for (char c : text) {
        if (c == '<') inTag = true;
        else if (c == '>') inTag = false;
        else if (!inTag) result += c;
    }
    return result;
}

int main() {
    ifstream inputFile("/Users/mateuszosak/Downloads/Takeout 3/YouTube i YouTube Music/historia/historia.html", ios::binary);
    string content((istreambuf_iterator<char>(inputFile)), (istreambuf_iterator<char>()));
    inputFile.close();

    ofstream outputFile("historia_youtube.csv");
    outputFile << "Autor,Data,Godzina" << endl;

    size_t pos = 0;
    while ((pos = content.find("Obejrzano:", pos)) != string::npos) {
        size_t endBlock = content.find("</div>", pos);
        if (endBlock == string::npos) break;

        string block = content.substr(pos, endBlock - pos);
        string author = "Nieznany";
        size_t firstA = block.find("<a ");
        
        if (firstA != string::npos) {
            size_t secondA = block.find("<a ", firstA + 1);
            if (secondA != string::npos) {
                size_t startName = block.find(">", secondA) + 1;
                size_t endName = block.find("</a>", startName);
                if (endName != string::npos) author = block.substr(startName, endName - startName);
            }
        }

        string datePart = "", timePart = "";
        size_t timePos = block.find(":"); 
        while(timePos != string::npos) {
            if (timePos > 2 && block[timePos+3] == ':') { 
                timePart = block.substr(timePos - 2, 8);
                size_t comma = block.rfind(",", timePos);
                if (comma != string::npos) {
                    size_t lastBr = block.rfind("<br>", comma);
                    if (lastBr != string::npos) datePart = block.substr(lastBr + 4, comma - (lastBr + 4));
                }
                break;
            }
            timePos = block.find(":", timePos + 1);
        }

        outputFile << "\"" << stripTags(author) << "\"," << stripTags(datePart) << "," << timePart << "\n";
        pos = endBlock; 
    }

    outputFile.close();
    return 0;
}