/* *****************************************************************************
 * A.L.E (Arcade Learning Environment)
 * Copyright (c) 2009-2013 by Yavar Naddaf, Joel Veness, Marc G. Bellemare,
 *  Matthew Hausknecht, and the Reinforcement Learning and Artificial Intelligence
 *  Laboratory
 * Released under the GNU General Public License; see License.txt for details.
 *
 * Based on: Stella  --  "An Atari 2600 VCS Emulator"
 * Copyright (c) 1995-2007 by Bradford W. Mott and the Stella team
 *
 * *****************************************************************************
 *  videoRecordingExample.cpp
 *
 *  An example on recording video with the ALE. This requires SDL.
 *  See manual for details.
 **************************************************************************** */

#include <iostream>
#include <ale_interface.hpp>
#include <cstdlib>

#ifndef __USE_SDL
#error Video recording example is disabled as it requires SDL. Recompile with -DUSE_SDL=ON.
#else

#include <SDL.h>



//MATLAB
#include "MatlabDataArray.hpp"
#include "MatlabEngine.hpp"
using namespace matlab::engine;



using namespace std;

int main(int argc, char** argv) {

	// Arrancar Matlab
	std::unique_ptr<MATLABEngine> matlabPtr = startMATLAB();
    	matlab::data::ArrayFactory factory;


    if (argc < 2) {
        std::cout << "Usage: " << argv[0] << " rom_file" << std::endl;
        return 1;
    }

    ALEInterface ale;

    // Get & Set the desired settings
    ale.setInt("random_seed", 123);

    // We enable both screen and sound, which we will need for recording.
    ale.setBool("display_screen", true);
    // You may leave sound disabled (by setting this flag to false) if so desired.
    ale.setBool("sound", false);

    std::string recordPath = "record";
    std::cout << std::endl;

    // Set record flags
    ale.setString("record_screen_dir", recordPath.c_str());
    ale.setString("record_sound_filename", (recordPath + "/sound.wav").c_str());
    // We set fragsize to 64 to ensure proper sound sync
    ale.setInt("fragsize", 64);

    // Not completely portable, but will work in most cases
    std::string cmd = "mkdir ";
    cmd += recordPath;
    system(cmd.c_str());

    // Load the ROM file. (Also resets the system for new settings to
    // take effect.)
    ale.loadROM(argv[1]);

    // Get the vector of legal actions
    ActionVect legal_actions = ale.getLegalActionSet();
	
	//VARIABLES
	int16_t nf = 12; //numero de features
	int16_t na = 3;//legal_actions.size(); //numero de acciones (en mi caso podría reducir a 3: stop, up, down)
	double features [nf] = {0,0,0,0,0,0,0,0,0,0,0,1}; //array de features + el 1
	double features_old [nf] = {0,0,0,0,0,0,0,0,0,0,0,1}; //array de features + el 1

	double w [na][nf]; //matriz de pesos

	double epsilon = 0.3;
	double alpha = 0.02;
	double gamma = 0.08;
	
	double Q [na];
	double Q_old;
	
	double max = 0.0;
	int16_t maxloc = 0;
	int16_t maxloc_old = 0;
	
	ActionVect acti = {legal_actions[0],legal_actions[2],legal_actions[5]};
	
	srand(time(NULL));
	int16_t counter = 0; //numero episodios
	double framenumber = 0;
	int16_t totalreward = 0;
	int16_t rewardsinepisode = 0;
	
	//INICIALIZAR PESOS Y Qs
	for(int i = 0; i < na; i++){
		Q[i]=0.0;
	    	for(int j = 0; j < nf; j++){
	    		w[i][j] = 0.01;
		}
	}
	
	//Abrir txt para escribir rewards
	std::ofstream ofile;
	ofile.open("rewards.txt", std::ios::app);
	
	
	Action a;

	a = legal_actions[0];
	ale.act(a);



//Bucle------------------------------
    while (!ale.game_over()) {
    	
    	//Caso final episode-----------------------------------------
    	if (ale.getFrameNumber()==8150){
    		//epsilon = epsilon - 0.1;  8150
    		
    		
    		counter=counter+1;
    		//rewardsinepisode=0;
    		
    		if(counter==8000){
    			exit(0);
    		}

    		ale.loadROM(argv[1]);
    		a = legal_actions[0];
		ale.act(a);
		
		// Pass vector containing 1 scalar arg (frame number)
   		std::vector<matlab::data::Array> args({factory.createScalar<int16_t>(ale.getFrameNumber())});
   		// Call MATLAB function 
        	matlabPtr->feval(u"alecode1", args);
   		// Get result from MATLAB function
		std::fstream myfile("positions.txt", std::ios_base::in);
    		myfile >> features[0] >> features[1] >> features[2] >> features[3] >> features[4] >> features[5] >> features[6] >> features[7] >> features[8] >> features[9] >> features[10];
		
		
		
		//escribir pesos en otro documento
		std::ofstream ofile2;
		ofile2.open("rewardsporepis.txt", std::ios::app);
		ofile2 << rewardsinepisode << std::endl;
		ofile2.close();
		
		rewardsinepisode=0;
		
		/*
		std::ofstream ofile2;
		ofile2.open("rewardsporepis.txt", std::ios::app);
		for(int i = 0; i < na; i++){
			ofile2 << "w[" << i << "][j]" << "	";
	    		for(int j = 0; j < nf; j++){
	    			ofile2 << w[i][j] << "	";
			}
			ofile2<< std::endl;
		}
		ofile2 << "----------------------------------------------"<< std::endl;
		ofile2.close();
		*/
		
    	}//End caso final episode-----------------------------------------
    	


    	for(int i = 0; i < nf; i++){
    		features_old[i]=features[i];
    	}
    	
    	//PARTE DE MATLAB----------------------------------------------
	
	// Pass vector containing 1 scalar arg (frame number)
   	std::vector<matlab::data::Array> args({factory.createScalar<int16_t>(ale.getFrameNumber())});
   	// Call MATLAB function 
        matlabPtr->feval(u"alecode1", args);
   	// Get result from MATLAB function
	std::fstream myfile("positions.txt", std::ios_base::in);
    	myfile >> features[0] >> features[1] >> features[2] >> features[3] >> features[4] >> features[5] >> features[6] >> features[7] >> features[8] >> features[9] >> features[10];

        std::cout << "Frame "<< ale.getFrameNumber() <<" : " << features[0] << " " << features[1] << " "  << features[2] << " "  << features[3] << " "  << features[4] << " "  << features[5] << " "  << features[6] << " "  << features[7] << " "  << features[8] << " "  << features[9] << " "  << features[10] << std::endl;
	
	//FIN DE LA PARTE DE MATLAB------------------------------------


    	
    	
    	
	//EPSILON GREEDY
	double random = ((double) rand() / (RAND_MAX));
	
	std::cout << "Episode: "<< counter << "  Recompensa total: " << totalreward << "  rec.episodio: " << rewardsinepisode << std::endl;
	
	if (random > epsilon){
		max = -50000000000;
		for (int i=0; i < na; i++){
			Q[i]=0.0;
			for (int j=0; j < nf; j++){
				Q[i] = Q[i] + w[i][j]*features[j];
			}
			if (max<Q[i]){
				max = Q[i];
				maxloc = i;
			}
			// std::cout << "Esta es la Q: "<< Q[i] <<" para la acción " << acti[i] << std::endl;
		}
		//Usar la acción con la Q más grande
		a = acti[maxloc];
		std::cout << "ELEGIDA ACCIÓN a: "<< a << std::endl;
	}
	else{
		//acción random
		
		double random = ((double) rand() / (RAND_MAX));
		if(random < 0.4){
			maxloc = 1;//go
		}
		else if(random < 0.8){
			maxloc = 0;//stop
		}
		else{
			maxloc = 2;//back
		}
		
		//maxloc = rand() % 3;
		a = acti[maxloc];
		std::cout << "                         ACCIÓN ALEATORIA a: "<< a << std::endl;
		Q[maxloc]=0.0;
		for (int j=0; j < nf; j++){
			Q[maxloc] = Q[maxloc] + w[maxloc][j]*features[j];
		}
	}

	//Enviar acción a la ale y obtener reward
	reward_t reward = ale.act(a);
	totalreward = totalreward+reward;
	rewardsinepisode=rewardsinepisode+reward;
	
	framenumber=framenumber+1;
	
	if(reward==1){
	//escribir el frame donde se obtiene reward en el documento
		ofile << framenumber << std::endl;
	}/*
	else if(features[0]!=0){
		reward=1-features[0];
	}*/

	//Calcular Q_old
	Q_old = 0.0;
	for (int j=0; j < nf; j++){
		Q_old = Q_old + w[maxloc_old][j]*features_old[j];
	}
	

	//ACTUALIZAR PESOS
	for(int i = 0; i < nf; i++){
		w[maxloc][i] = w[maxloc][i] + alpha*(reward + gamma*(Q[maxloc])-(Q_old))*features[i];
	}
	
	maxloc_old = maxloc;
	
	
	
	
}//final while -----------------------------------------------------------------------------------------------------------------------------
	
    ofile.close();

    std::cout << std::endl;
    std::cout << "Recording complete. To create a video, you may want to run \n"
        "  doc/scripts/videoRecordingExampleJoinXXX.sh. See manual for details.." << std::endl;

    return 0;
}
#endif // __USE_SDL
