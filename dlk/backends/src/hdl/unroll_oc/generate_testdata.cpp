#include <iostream>
#include <cstdio>
#include <vector>
#include <random>
#include <cstdint>
using namespace std;

static const int InBitPrecision = 2;
static const int InChHighMax = 32;
static const int OutChUnroll = 16;
static const int KernelSize = 3;
static const int TileSize = 32;

using InWord = uint32_t;
using OutWord = int16_t;

// using InData = InWord[InBitPrecision];
// using KnData = InWord[KernelSize][KernelSize];
// using OutData = OutWord;


// OutWord rand

InWord indata[TileSize][TileSize][InChHighMax][InBitPrecision];
InWord kndata[3][3][OutChUnroll][InChHighMax];
OutWord out_check_data [TileSize][TileSize][OutChUnroll];

    

int main(int argc, char const *argv[])
{

    int input_height = 64;
    int input_width = 64;
    int padding = 1;
    int kernel_size = 3;
    int output_height = input_height - (kernel_size-1) +padding *2; 
    int output_width = input_width - (kernel_size-1) +padding *2; 
    int input_channels = 4; //high
    int output_channels = 16; //high

    FILE * fp;

std::random_device rnd;

// 入力データ生成。
    for(int ih = 0; ih < TileSize; ih++){
        for(int iw = 0; iw < TileSize ; iw++){
            for(int ic = 0; ic < InChHighMax; ic++ ){
                for(int ib = 0; ib < InBitPrecision; ib++){
                    if(ic >= 4|| ih==0||ih==TileSize-1||iw==0||iw==TileSize-1)
                        indata[ih][iw][ic][ib] = 0;
                    else 
                        indata[ih][iw][ic][ib] = rnd();
                }
            }
        }
    }        

// カーネルデータ生成
    for(int kh = 0; kh < 3 ; kh++){
        for(int kw = 0; kw < 3; kw++){
            for(int oc = 0; oc < OutChUnroll; oc++){
                for(int ic = 0; ic < InChHighMax; ic++){
                    if(ic<4)
                    kndata[kh][kw][oc][ic] = rnd();
                    else 
                    kndata[kh][kw][oc][ic] = 0;
                }
            }
        }
    }

// 出力データ計算。
    int ih,iw;
    for(int oh = 0; oh < TileSize ; oh++){
        for(int ow = 0; ow < TileSize ; ow++){
            ih = oh;
            iw = ow;
            for(int oc = 0; oc < OutChUnroll; oc++){
                out_check_data[oh][ow][oc] = 0;
                if(oh>=TileSize-2 || ow>=TileSize-2  ) continue;
                for(int ic = 0; ic < InChHighMax; ic++ ){
                    if(ic<4){
                        for(int ib = 0; ib < InBitPrecision; ib++){
                            out_check_data[oh][ow][oc] += (__builtin_popcount(~( indata[ih][iw][ic][ib] ^ kndata[0][0][oc][ic])) -  __builtin_popcount(~kndata[0][0][oc][ic])) << ib  ; 
                        }
                    }
                }
                
            }
        }
    }

// 入力データ書き出し　１ファイル(ic,ih_low,iw_low)
    char filename[128];
    for(int ib = 0; ib < InBitPrecision; ib++){
        sprintf(filename,"inbuf%02d.txt",ib);
        fp = fopen(filename,"w");
        for(int ih = 0; ih < TileSize; ih++){
            for(int iw = 0; iw < TileSize ; iw++){
                for(int ic = 0; ic < InChHighMax; ic++ ){                    
                    fprintf(fp,"%08X\n",indata[ih][iw][ic][ib]);
                }
            }
        }
        fclose(fp);        
    }

    int kh=0;
    int kw=0;

// カーネルデータ書き出し Nファイル(ic,kh,kw)[N]
    for(int oc = 0; oc < OutChUnroll; oc++){
        sprintf(filename,"knbuf%02d.txt",oc);
        fp = fopen(filename,"w");
        // for(int kh = 0; kh < 3 ; kh++){
            // for(int kw = 0; kw < 3; kw++){
                for(int ic = 0; ic < InChHighMax; ic++){
                    fprintf(fp,"%08X\n",kndata[0][0][oc][ic]);
                }
            // }
        // }
        fclose(fp);
    }


// 出力データ書き出し Nファイル(oh,ow)[N]
    
    fp = fopen("out_check.txt","w");    
    char delimit[2] = {'_','\n'};
    for(int oh = 0; oh < TileSize; oh++){
        for(int ow = 0; ow < TileSize ; ow++){
            for(int oc = OutChUnroll - 1 ; oc >= 0; oc--){
                fprintf(fp,"%04X%c", (unsigned short)out_check_data[oh][ow][oc],delimit[oc==0]);
            }
        }
    }
    fclose(fp);


    return 0;
}
