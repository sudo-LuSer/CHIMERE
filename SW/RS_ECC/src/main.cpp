#include <bits/stdc++.h>
#include "RS_tools.hpp"
#include "RS_Decoder.hpp"

#define pb push_back 

int main(int argc,char** argv) {
    int m = 3;
    int n  = (1 << m) - 1;
    int k = 3;
    int t = (n - k) / 2;

    GaloisField gf(m);
    RS_Decoder dec(n, k, gf); 



    for (int i = 1; i < argc; ++i) {
        unsigned char *conv_in = reinterpret_cast <unsigned char*> (argv[i]);
        std :: vector <int> received_msg;
        for(int j = 0 ; conv_in[j] ; ++j){
            received_msg.pb(conv_in[j] - 48);
        }

        // error injection

        //received_msg[1] = 1;

        //std :: cout << "AFFICHAGE Du MESSAGE RECU : " << std :: endl; 
        //for(auto x : received_msg)
            //std :: cout << x << " "; 

        std :: vector <int> decoded_msg = dec.decode(received_msg);
        //std :: cout << "AFFICHAGE Du MESSAGE DECODER : " << std :: endl; 
        for(auto x : decoded_msg)
            std :: cout << x << " "; 
        std :: cout << std :: endl;
    }   
}