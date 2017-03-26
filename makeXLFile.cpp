#include <string>
#include <vector>
#include <iostream>
#include <fstream>
#include <sstream>
#include <cstring>
#include <bits/stdc++.h>
using namespace std;
class CSVRow
{
    public:
        std::string const& operator[](std::size_t index) const
        {
            return m_data[index];
        }
        std::size_t size() const
        {
            return m_data.size();
        }
        void readNextRow(std::istream& str)
        {
            std::string         line;
            std::getline(str, line);

            std::stringstream   lineStream(line);
            std::string         cell;

            m_data.clear();
            while(std::getline(lineStream, cell, ','))
            {
                m_data.push_back(cell);
            }
        }
    private:
        std::vector<std::string>    m_data;
};

std::istream& operator>>(std::istream& str, CSVRow& data)
{
    data.readNextRow(str);
    return str;
}   
class GazeInfo
{
public:
	int frame_no;
	int line_no;
	int token_id;
	string token_value;
	float gaze_x;
	float gaze_y;
	int x_start;
	int x_end;
	int y_start;
	int y_end;

	GazeInfo(int frame_no, int line_no, string token_value, float gaze_x, float gaze_y, int x_start, int x_end, int y_start, int y_end){
		this->frame_no = frame_no;
		this->line_no = line_no;
		this->token_id = 0;
		this->token_value = token_value;
		this->gaze_x = gaze_x;
		this->gaze_y = gaze_y;
		this->x_start = x_start;
		this->x_end = x_end;
		this->y_start = y_start;
		this->y_end = y_end;
	}
	~GazeInfo(){}
	
};
class TokenInfo
{
public:
	int frame_no;
	int token_id;
	int line_no;
	string token_value;
	int x_start;
	int x_end;
	int y_start;
	int y_end;

	TokenInfo(int frame_no, int token_id, int line_no, string token_value, int x_start, int x_end, int y_start, int y_end){
		this->frame_no = frame_no;
		this->token_id = token_id;
		this->line_no = line_no;
		this->token_value = token_value;
		this->x_start = x_start;
		this->x_end = x_end;
		this->y_start = y_start;
		this->y_end = y_end;
	}
	~TokenInfo(){}
	
};
int main()
{
    std::ifstream       file("Token_info.csv");
    ifstream file1("FinalMatrix.csv");
    CSVRow              row, row1;
    vector<GazeInfo> gaze_list;
    vector<TokenInfo> token_list;
    int id = 0, line_no = 0;
    file1 >> row1;
    file >> row;
    while(file1 >> row1)
    {
        if(row1[2] == "blank")
        	continue;
        else{
        	// cout << row1[6];
        	gaze_list.push_back(GazeInfo(stoi(row1[0]), stoi(row1[1]), row1[2], stof(row1[6]),stof(row1[7]), -1, -1, -1, -1));
        }
    }
    while(file >> row){
    	try{
    		if(line_no < stoi(row[1])){
    			line_no = stoi(row[1]);
    			id = 0;
    		}
    		// cout << row[3] << endl;
    		int x_start = stoi(row[3]);
    		int y_start = stoi(row[4]);
    		int width = stoi(row[5]);
    		int height = stoi(row[6]);
    		int x_end = x_start + width;
    		int y_end = y_start + height;
    		token_list.push_back(TokenInfo(stoi(row[0]), id++, line_no, row[2], x_start, x_end, y_start, y_end));
    	}
    	catch(...){
    		continue;
    	}
    }
    for(int i = 0; i < gaze_list.size(); i++){
    	for(auto j: token_list){
    		if(gaze_list[i].frame_no != j.frame_no)
    			continue;
    		if(gaze_list[i].line_no != j.line_no)
    			continue;
    		if(gaze_list[i].gaze_x >= j.x_start && gaze_list[i].gaze_x <= j.x_end){
    			gaze_list[i].x_start = j.x_start;
    			gaze_list[i].x_end = j.x_end;
    			gaze_list[i].y_start = j.y_start;
    			gaze_list[i].y_end = j.y_end;
    			gaze_list[i].token_id = j.token_id;
    			// cout << gaze_list[i].frame_no << " " << gaze_list[i].line_no << " " << gaze_list[i].token_id << " " << gaze_list[i].token_value << " " << gaze_list[i].gaze_x << " " << gaze_list[i].x_start << " " << gaze_list[i].x_end << endl;

    		}
    	}
    }
    unordered_map<int, int> hash;
    CSVRow row2;
    ifstream file2("Frame_Displacement.csv");
    file2 >> row2;
    while(file2 >> row2){
    	try{
    		int net_disp = 0;
    		int frame = stoi(row2[0]);
    		int displacement = stoi(row2[1]);
    		cout << row2[0] << " " << row2[1] << " " << row2[2] << endl;
    		int scroll = stoi(row2[2]);
    		if(scroll == 2)
    			displacement = -displacement;
			net_disp += displacement;
    		hash[frame] = net_disp;
    	}
    	catch(...){
    		continue;
    	}
    }	
    for(int i = 0; i < gaze_list.size(); i++){
    	gaze_list[i].gaze_y += hash[gaze_list[i].frame_no];
    	gaze_list[i].y_start += hash[gaze_list[i].frame_no];
    	gaze_list[i].y_end += hash[gaze_list[i].frame_no];
    }
    ofstream myfile;
    myfile.open("output.csv");
   	myfile << "Frame_no,Line_no,Token_id,Token_value,Gaze_X,Gaze_Y,X_start,X_end,Y_start,Y_end" <<endl;
    for(auto i: gaze_list){
    	// cout << i.frame_no << "," << i.line_no << "," << i.token_id << "," << i.token_value << "," << i.gaze_x << "," << i.gaze_y << "," << i.x_start << "," << i.x_end << "," << i.y_start << "," << i.y_end << endl;
    	myfile << i.frame_no << "," << i.line_no << "," << i.token_id << "," << i.token_value << "," << i.gaze_x << "," << i.gaze_y << "," << i.x_start << "," << i.x_end << "," << i.y_start << "," << i.y_end << endl;
    }
    myfile.close();
}