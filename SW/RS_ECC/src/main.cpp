#include <bits/stdc++.h> 

#include "RS_tools.hpp"
#include "RS_Decoder.hpp"

std::vector<int> bits21_to_symbols(uint32_t data) {
    std::vector<int> symbols(7);
    for (int i = 0; i < 7; ++i)
        symbols[i] = (data >> (3 * i)) & 0x7;
    return symbols;
}

uint8_t symbols_to_byte(const std::vector<int>& msg) {
    if (msg.size() < 3) return 0;
    return (msg[2] << 6) | (msg[1] << 3) | msg[0];
}

std::vector<int> parse_symbol_string(const std::string& s) {
    std::vector<int> res;
    for (char c : s) {
        if (c < '0' || c > '7')
            throw std::runtime_error("Caractere invalide");
        res.push_back(c - '0');
    }
    return res;
}

int main(int argc, char* argv[]) {
    if (argc < 2) {
        std::cerr << "Usage: " << argv[0] << " <mot_de_code> [<mot_de_code> ...]\n";
        return 1;
    }

    int m = 3;
    int n = (1 << m) - 1;
    int k = 3;
    GaloisField gf(m);
    RS_Decoder decoder(n, k, gf);

    for (int i = 1; i < argc; ++i) {
        std::string arg(argv[i]);
        std::vector<int> received;

        if (arg.rfind("0x", 0) == 0) {
            uint32_t val = std::stoul(arg, nullptr, 16);
            received = bits21_to_symbols(val);
        } 
        
        else {
            received = parse_symbol_string(arg);
            if (received.size() != 7) {
                std::cerr << "Erreur : 7 symboles attendus\n";
                continue;
            }
        }

        std::vector<int> corrected = decoder.decode(received);
        std::vector<int> message(corrected.begin(), corrected.begin() + k);

        // std::cout << "Entree : ";
        // for (int x : received) std::cout << x << " ";
        // std::cout << "-> Corrige : ";
        // for (int x : corrected) std::cout << x << " ";
        // std::cout << "-> Message : ";
        // for (int x : message) std::cout << x << " ";

        uint8_t ch = symbols_to_byte(message);
        // std::cout << "-> Caractere : '" << (char)ch << "' (0x" << std::hex << (int)ch << std::dec << ")\n";
        std :: cout << std :: hex << ch << std :: endl; 
    }

    return 0;
}
