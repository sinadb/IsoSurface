//
//  IBL.metal
//  MetalProject
//
//  Created by Sina Dashtebozorgy on 24/01/2024.
//

#include <metal_stdlib>
#include "ShaderDefinitions.h"


using namespace metal;

static constant int edgeConnections[12][2] = {
        {0,1}, {1,2}, {2,3}, {3,0},
        {4,5}, {5,6}, {6,7}, {7,4},
        {0,4}, {1,5}, {2,6}, {3,7}
};

static constant float3 cornerOffsets[8] = {
        float3(0, 0, 1),
        float3(1, 0, 1),
        float3(1, 0, 0),
        float3(0, 0, 0),
        float3(0, 1, 1),
        float3(1, 1, 1),
        float3(1, 1, 0),
        float3(0, 1, 0)
};

static constant int triTable[256][16] = {
        {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {0, 8, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {0, 1, 9, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {1, 8, 3, 9, 8, 1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {1, 2, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {0, 8, 3, 1, 2, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {9, 2, 10, 0, 2, 9, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {2, 8, 3, 2, 10, 8, 10, 9, 8, -1, -1, -1, -1, -1, -1, -1},
        {3, 11, 2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {0, 11, 2, 8, 11, 0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {1, 9, 0, 2, 3, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {1, 11, 2, 1, 9, 11, 9, 8, 11, -1, -1, -1, -1, -1, -1, -1},
        {3, 10, 1, 11, 10, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {0, 10, 1, 0, 8, 10, 8, 11, 10, -1, -1, -1, -1, -1, -1, -1},
        {3, 9, 0, 3, 11, 9, 11, 10, 9, -1, -1, -1, -1, -1, -1, -1},
        {9, 8, 10, 10, 8, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {4, 7, 8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {4, 3, 0, 7, 3, 4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {0, 1, 9, 8, 4, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {4, 1, 9, 4, 7, 1, 7, 3, 1, -1, -1, -1, -1, -1, -1, -1},
        {1, 2, 10, 8, 4, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {3, 4, 7, 3, 0, 4, 1, 2, 10, -1, -1, -1, -1, -1, -1, -1},
        {9, 2, 10, 9, 0, 2, 8, 4, 7, -1, -1, -1, -1, -1, -1, -1},
        {2, 10, 9, 2, 9, 7, 2, 7, 3, 7, 9, 4, -1, -1, -1, -1},
        {8, 4, 7, 3, 11, 2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {11, 4, 7, 11, 2, 4, 2, 0, 4, -1, -1, -1, -1, -1, -1, -1},
        {9, 0, 1, 8, 4, 7, 2, 3, 11, -1, -1, -1, -1, -1, -1, -1},
        {4, 7, 11, 9, 4, 11, 9, 11, 2, 9, 2, 1, -1, -1, -1, -1},
        {3, 10, 1, 3, 11, 10, 7, 8, 4, -1, -1, -1, -1, -1, -1, -1},
        {1, 11, 10, 1, 4, 11, 1, 0, 4, 7, 11, 4, -1, -1, -1, -1},
        {4, 7, 8, 9, 0, 11, 9, 11, 10, 11, 0, 3, -1, -1, -1, -1},
        {4, 7, 11, 4, 11, 9, 9, 11, 10, -1, -1, -1, -1, -1, -1, -1},
        {9, 5, 4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {9, 5, 4, 0, 8, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {0, 5, 4, 1, 5, 0, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {8, 5, 4, 8, 3, 5, 3, 1, 5, -1, -1, -1, -1, -1, -1, -1},
        {1, 2, 10, 9, 5, 4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {3, 0, 8, 1, 2, 10, 4, 9, 5, -1, -1, -1, -1, -1, -1, -1},
        {5, 2, 10, 5, 4, 2, 4, 0, 2, -1, -1, -1, -1, -1, -1, -1},
        {2, 10, 5, 3, 2, 5, 3, 5, 4, 3, 4, 8, -1, -1, -1, -1},
        {9, 5, 4, 2, 3, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {0, 11, 2, 0, 8, 11, 4, 9, 5, -1, -1, -1, -1, -1, -1, -1},
        {0, 5, 4, 0, 1, 5, 2, 3, 11, -1, -1, -1, -1, -1, -1, -1},
        {2, 1, 5, 2, 5, 8, 2, 8, 11, 4, 8, 5, -1, -1, -1, -1},
        {10, 3, 11, 10, 1, 3, 9, 5, 4, -1, -1, -1, -1, -1, -1, -1},
        {4, 9, 5, 0, 8, 1, 8, 10, 1, 8, 11, 10, -1, -1, -1, -1},
        {5, 4, 0, 5, 0, 11, 5, 11, 10, 11, 0, 3, -1, -1, -1, -1},
        {5, 4, 8, 5, 8, 10, 10, 8, 11, -1, -1, -1, -1, -1, -1, -1},
        {9, 7, 8, 5, 7, 9, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {9, 3, 0, 9, 5, 3, 5, 7, 3, -1, -1, -1, -1, -1, -1, -1},
        {0, 7, 8, 0, 1, 7, 1, 5, 7, -1, -1, -1, -1, -1, -1, -1},
        {1, 5, 3, 3, 5, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {9, 7, 8, 9, 5, 7, 10, 1, 2, -1, -1, -1, -1, -1, -1, -1},
        {10, 1, 2, 9, 5, 0, 5, 3, 0, 5, 7, 3, -1, -1, -1, -1},
        {8, 0, 2, 8, 2, 5, 8, 5, 7, 10, 5, 2, -1, -1, -1, -1},
        {2, 10, 5, 2, 5, 3, 3, 5, 7, -1, -1, -1, -1, -1, -1, -1},
        {7, 9, 5, 7, 8, 9, 3, 11, 2, -1, -1, -1, -1, -1, -1, -1},
        {9, 5, 7, 9, 7, 2, 9, 2, 0, 2, 7, 11, -1, -1, -1, -1},
        {2, 3, 11, 0, 1, 8, 1, 7, 8, 1, 5, 7, -1, -1, -1, -1},
        {11, 2, 1, 11, 1, 7, 7, 1, 5, -1, -1, -1, -1, -1, -1, -1},
        {9, 5, 8, 8, 5, 7, 10, 1, 3, 10, 3, 11, -1, -1, -1, -1},
        {5, 7, 0, 5, 0, 9, 7, 11, 0, 1, 0, 10, 11, 10, 0, -1},
        {11, 10, 0, 11, 0, 3, 10, 5, 0, 8, 0, 7, 5, 7, 0, -1},
        {11, 10, 5, 7, 11, 5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {10, 6, 5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {0, 8, 3, 5, 10, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {9, 0, 1, 5, 10, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {1, 8, 3, 1, 9, 8, 5, 10, 6, -1, -1, -1, -1, -1, -1, -1},
        {1, 6, 5, 2, 6, 1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {1, 6, 5, 1, 2, 6, 3, 0, 8, -1, -1, -1, -1, -1, -1, -1},
        {9, 6, 5, 9, 0, 6, 0, 2, 6, -1, -1, -1, -1, -1, -1, -1},
        {5, 9, 8, 5, 8, 2, 5, 2, 6, 3, 2, 8, -1, -1, -1, -1},
        {2, 3, 11, 10, 6, 5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {11, 0, 8, 11, 2, 0, 10, 6, 5, -1, -1, -1, -1, -1, -1, -1},
        {0, 1, 9, 2, 3, 11, 5, 10, 6, -1, -1, -1, -1, -1, -1, -1},
        {5, 10, 6, 1, 9, 2, 9, 11, 2, 9, 8, 11, -1, -1, -1, -1},
        {6, 3, 11, 6, 5, 3, 5, 1, 3, -1, -1, -1, -1, -1, -1, -1},
        {0, 8, 11, 0, 11, 5, 0, 5, 1, 5, 11, 6, -1, -1, -1, -1},
        {3, 11, 6, 0, 3, 6, 0, 6, 5, 0, 5, 9, -1, -1, -1, -1},
        {6, 5, 9, 6, 9, 11, 11, 9, 8, -1, -1, -1, -1, -1, -1, -1},
        {5, 10, 6, 4, 7, 8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {4, 3, 0, 4, 7, 3, 6, 5, 10, -1, -1, -1, -1, -1, -1, -1},
        {1, 9, 0, 5, 10, 6, 8, 4, 7, -1, -1, -1, -1, -1, -1, -1},
        {10, 6, 5, 1, 9, 7, 1, 7, 3, 7, 9, 4, -1, -1, -1, -1},
        {6, 1, 2, 6, 5, 1, 4, 7, 8, -1, -1, -1, -1, -1, -1, -1},
        {1, 2, 5, 5, 2, 6, 3, 0, 4, 3, 4, 7, -1, -1, -1, -1},
        {8, 4, 7, 9, 0, 5, 0, 6, 5, 0, 2, 6, -1, -1, -1, -1},
        {7, 3, 9, 7, 9, 4, 3, 2, 9, 5, 9, 6, 2, 6, 9, -1},
        {3, 11, 2, 7, 8, 4, 10, 6, 5, -1, -1, -1, -1, -1, -1, -1},
        {5, 10, 6, 4, 7, 2, 4, 2, 0, 2, 7, 11, -1, -1, -1, -1},
        {0, 1, 9, 4, 7, 8, 2, 3, 11, 5, 10, 6, -1, -1, -1, -1},
        {9, 2, 1, 9, 11, 2, 9, 4, 11, 7, 11, 4, 5, 10, 6, -1},
        {8, 4, 7, 3, 11, 5, 3, 5, 1, 5, 11, 6, -1, -1, -1, -1},
        {5, 1, 11, 5, 11, 6, 1, 0, 11, 7, 11, 4, 0, 4, 11, -1},
        {0, 5, 9, 0, 6, 5, 0, 3, 6, 11, 6, 3, 8, 4, 7, -1},
        {6, 5, 9, 6, 9, 11, 4, 7, 9, 7, 11, 9, -1, -1, -1, -1},
        {10, 4, 9, 6, 4, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {4, 10, 6, 4, 9, 10, 0, 8, 3, -1, -1, -1, -1, -1, -1, -1},
        {10, 0, 1, 10, 6, 0, 6, 4, 0, -1, -1, -1, -1, -1, -1, -1},
        {8, 3, 1, 8, 1, 6, 8, 6, 4, 6, 1, 10, -1, -1, -1, -1},
        {1, 4, 9, 1, 2, 4, 2, 6, 4, -1, -1, -1, -1, -1, -1, -1},
        {3, 0, 8, 1, 2, 9, 2, 4, 9, 2, 6, 4, -1, -1, -1, -1},
        {0, 2, 4, 4, 2, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {8, 3, 2, 8, 2, 4, 4, 2, 6, -1, -1, -1, -1, -1, -1, -1},
        {10, 4, 9, 10, 6, 4, 11, 2, 3, -1, -1, -1, -1, -1, -1, -1},
        {0, 8, 2, 2, 8, 11, 4, 9, 10, 4, 10, 6, -1, -1, -1, -1},
        {3, 11, 2, 0, 1, 6, 0, 6, 4, 6, 1, 10, -1, -1, -1, -1},
        {6, 4, 1, 6, 1, 10, 4, 8, 1, 2, 1, 11, 8, 11, 1, -1},
        {9, 6, 4, 9, 3, 6, 9, 1, 3, 11, 6, 3, -1, -1, -1, -1},
        {8, 11, 1, 8, 1, 0, 11, 6, 1, 9, 1, 4, 6, 4, 1, -1},
        {3, 11, 6, 3, 6, 0, 0, 6, 4, -1, -1, -1, -1, -1, -1, -1},
        {6, 4, 8, 11, 6, 8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {7, 10, 6, 7, 8, 10, 8, 9, 10, -1, -1, -1, -1, -1, -1, -1},
        {0, 7, 3, 0, 10, 7, 0, 9, 10, 6, 7, 10, -1, -1, -1, -1},
        {10, 6, 7, 1, 10, 7, 1, 7, 8, 1, 8, 0, -1, -1, -1, -1},
        {10, 6, 7, 10, 7, 1, 1, 7, 3, -1, -1, -1, -1, -1, -1, -1},
        {1, 2, 6, 1, 6, 8, 1, 8, 9, 8, 6, 7, -1, -1, -1, -1},
        {2, 6, 9, 2, 9, 1, 6, 7, 9, 0, 9, 3, 7, 3, 9, -1},
        {7, 8, 0, 7, 0, 6, 6, 0, 2, -1, -1, -1, -1, -1, -1, -1},
        {7, 3, 2, 6, 7, 2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {2, 3, 11, 10, 6, 8, 10, 8, 9, 8, 6, 7, -1, -1, -1, -1},
        {2, 0, 7, 2, 7, 11, 0, 9, 7, 6, 7, 10, 9, 10, 7, -1},
        {1, 8, 0, 1, 7, 8, 1, 10, 7, 6, 7, 10, 2, 3, 11, -1},
        {11, 2, 1, 11, 1, 7, 10, 6, 1, 6, 7, 1, -1, -1, -1, -1},
        {8, 9, 6, 8, 6, 7, 9, 1, 6, 11, 6, 3, 1, 3, 6, -1},
        {0, 9, 1, 11, 6, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {7, 8, 0, 7, 0, 6, 3, 11, 0, 11, 6, 0, -1, -1, -1, -1},
        {7, 11, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {7, 6, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {3, 0, 8, 11, 7, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {0, 1, 9, 11, 7, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {8, 1, 9, 8, 3, 1, 11, 7, 6, -1, -1, -1, -1, -1, -1, -1},
        {10, 1, 2, 6, 11, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {1, 2, 10, 3, 0, 8, 6, 11, 7, -1, -1, -1, -1, -1, -1, -1},
        {2, 9, 0, 2, 10, 9, 6, 11, 7, -1, -1, -1, -1, -1, -1, -1},
        {6, 11, 7, 2, 10, 3, 10, 8, 3, 10, 9, 8, -1, -1, -1, -1},
        {7, 2, 3, 6, 2, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {7, 0, 8, 7, 6, 0, 6, 2, 0, -1, -1, -1, -1, -1, -1, -1},
        {2, 7, 6, 2, 3, 7, 0, 1, 9, -1, -1, -1, -1, -1, -1, -1},
        {1, 6, 2, 1, 8, 6, 1, 9, 8, 8, 7, 6, -1, -1, -1, -1},
        {10, 7, 6, 10, 1, 7, 1, 3, 7, -1, -1, -1, -1, -1, -1, -1},
        {10, 7, 6, 1, 7, 10, 1, 8, 7, 1, 0, 8, -1, -1, -1, -1},
        {0, 3, 7, 0, 7, 10, 0, 10, 9, 6, 10, 7, -1, -1, -1, -1},
        {7, 6, 10, 7, 10, 8, 8, 10, 9, -1, -1, -1, -1, -1, -1, -1},
        {6, 8, 4, 11, 8, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {3, 6, 11, 3, 0, 6, 0, 4, 6, -1, -1, -1, -1, -1, -1, -1},
        {8, 6, 11, 8, 4, 6, 9, 0, 1, -1, -1, -1, -1, -1, -1, -1},
        {9, 4, 6, 9, 6, 3, 9, 3, 1, 11, 3, 6, -1, -1, -1, -1},
        {6, 8, 4, 6, 11, 8, 2, 10, 1, -1, -1, -1, -1, -1, -1, -1},
        {1, 2, 10, 3, 0, 11, 0, 6, 11, 0, 4, 6, -1, -1, -1, -1},
        {4, 11, 8, 4, 6, 11, 0, 2, 9, 2, 10, 9, -1, -1, -1, -1},
        {10, 9, 3, 10, 3, 2, 9, 4, 3, 11, 3, 6, 4, 6, 3, -1},
        {8, 2, 3, 8, 4, 2, 4, 6, 2, -1, -1, -1, -1, -1, -1, -1},
        {0, 4, 2, 4, 6, 2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {1, 9, 0, 2, 3, 4, 2, 4, 6, 4, 3, 8, -1, -1, -1, -1},
        {1, 9, 4, 1, 4, 2, 2, 4, 6, -1, -1, -1, -1, -1, -1, -1},
        {8, 1, 3, 8, 6, 1, 8, 4, 6, 6, 10, 1, -1, -1, -1, -1},
        {10, 1, 0, 10, 0, 6, 6, 0, 4, -1, -1, -1, -1, -1, -1, -1},
        {4, 6, 3, 4, 3, 8, 6, 10, 3, 0, 3, 9, 10, 9, 3, -1},
        {10, 9, 4, 6, 10, 4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {4, 9, 5, 7, 6, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {0, 8, 3, 4, 9, 5, 11, 7, 6, -1, -1, -1, -1, -1, -1, -1},
        {5, 0, 1, 5, 4, 0, 7, 6, 11, -1, -1, -1, -1, -1, -1, -1},
        {11, 7, 6, 8, 3, 4, 3, 5, 4, 3, 1, 5, -1, -1, -1, -1},
        {9, 5, 4, 10, 1, 2, 7, 6, 11, -1, -1, -1, -1, -1, -1, -1},
        {6, 11, 7, 1, 2, 10, 0, 8, 3, 4, 9, 5, -1, -1, -1, -1},
        {7, 6, 11, 5, 4, 10, 4, 2, 10, 4, 0, 2, -1, -1, -1, -1},
        {3, 4, 8, 3, 5, 4, 3, 2, 5, 10, 5, 2, 11, 7, 6, -1},
        {7, 2, 3, 7, 6, 2, 5, 4, 9, -1, -1, -1, -1, -1, -1, -1},
        {9, 5, 4, 0, 8, 6, 0, 6, 2, 6, 8, 7, -1, -1, -1, -1},
        {3, 6, 2, 3, 7, 6, 1, 5, 0, 5, 4, 0, -1, -1, -1, -1},
        {6, 2, 8, 6, 8, 7, 2, 1, 8, 4, 8, 5, 1, 5, 8, -1},
        {9, 5, 4, 10, 1, 6, 1, 7, 6, 1, 3, 7, -1, -1, -1, -1},
        {1, 6, 10, 1, 7, 6, 1, 0, 7, 8, 7, 0, 9, 5, 4, -1},
        {4, 0, 10, 4, 10, 5, 0, 3, 10, 6, 10, 7, 3, 7, 10, -1},
        {7, 6, 10, 7, 10, 8, 5, 4, 10, 4, 8, 10, -1, -1, -1, -1},
        {6, 9, 5, 6, 11, 9, 11, 8, 9, -1, -1, -1, -1, -1, -1, -1},
        {3, 6, 11, 0, 6, 3, 0, 5, 6, 0, 9, 5, -1, -1, -1, -1},
        {0, 11, 8, 0, 5, 11, 0, 1, 5, 5, 6, 11, -1, -1, -1, -1},
        {6, 11, 3, 6, 3, 5, 5, 3, 1, -1, -1, -1, -1, -1, -1, -1},
        {1, 2, 10, 9, 5, 11, 9, 11, 8, 11, 5, 6, -1, -1, -1, -1},
        {0, 11, 3, 0, 6, 11, 0, 9, 6, 5, 6, 9, 1, 2, 10, -1},
        {11, 8, 5, 11, 5, 6, 8, 0, 5, 10, 5, 2, 0, 2, 5, -1},
        {6, 11, 3, 6, 3, 5, 2, 10, 3, 10, 5, 3, -1, -1, -1, -1},
        {5, 8, 9, 5, 2, 8, 5, 6, 2, 3, 8, 2, -1, -1, -1, -1},
        {9, 5, 6, 9, 6, 0, 0, 6, 2, -1, -1, -1, -1, -1, -1, -1},
        {1, 5, 8, 1, 8, 0, 5, 6, 8, 3, 8, 2, 6, 2, 8, -1},
        {1, 5, 6, 2, 1, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {1, 3, 6, 1, 6, 10, 3, 8, 6, 5, 6, 9, 8, 9, 6, -1},
        {10, 1, 0, 10, 0, 6, 9, 5, 0, 5, 6, 0, -1, -1, -1, -1},
        {0, 3, 8, 5, 6, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {10, 5, 6, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {11, 5, 10, 7, 5, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {11, 5, 10, 11, 7, 5, 8, 3, 0, -1, -1, -1, -1, -1, -1, -1},
        {5, 11, 7, 5, 10, 11, 1, 9, 0, -1, -1, -1, -1, -1, -1, -1},
        {10, 7, 5, 10, 11, 7, 9, 8, 1, 8, 3, 1, -1, -1, -1, -1},
        {11, 1, 2, 11, 7, 1, 7, 5, 1, -1, -1, -1, -1, -1, -1, -1},
        {0, 8, 3, 1, 2, 7, 1, 7, 5, 7, 2, 11, -1, -1, -1, -1},
        {9, 7, 5, 9, 2, 7, 9, 0, 2, 2, 11, 7, -1, -1, -1, -1},
        {7, 5, 2, 7, 2, 11, 5, 9, 2, 3, 2, 8, 9, 8, 2, -1},
        {2, 5, 10, 2, 3, 5, 3, 7, 5, -1, -1, -1, -1, -1, -1, -1},
        {8, 2, 0, 8, 5, 2, 8, 7, 5, 10, 2, 5, -1, -1, -1, -1},
        {9, 0, 1, 5, 10, 3, 5, 3, 7, 3, 10, 2, -1, -1, -1, -1},
        {9, 8, 2, 9, 2, 1, 8, 7, 2, 10, 2, 5, 7, 5, 2, -1},
        {1, 3, 5, 3, 7, 5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {0, 8, 7, 0, 7, 1, 1, 7, 5, -1, -1, -1, -1, -1, -1, -1},
        {9, 0, 3, 9, 3, 5, 5, 3, 7, -1, -1, -1, -1, -1, -1, -1},
        {9, 8, 7, 5, 9, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {5, 8, 4, 5, 10, 8, 10, 11, 8, -1, -1, -1, -1, -1, -1, -1},
        {5, 0, 4, 5, 11, 0, 5, 10, 11, 11, 3, 0, -1, -1, -1, -1},
        {0, 1, 9, 8, 4, 10, 8, 10, 11, 10, 4, 5, -1, -1, -1, -1},
        {10, 11, 4, 10, 4, 5, 11, 3, 4, 9, 4, 1, 3, 1, 4, -1},
        {2, 5, 1, 2, 8, 5, 2, 11, 8, 4, 5, 8, -1, -1, -1, -1},
        {0, 4, 11, 0, 11, 3, 4, 5, 11, 2, 11, 1, 5, 1, 11, -1},
        {0, 2, 5, 0, 5, 9, 2, 11, 5, 4, 5, 8, 11, 8, 5, -1},
        {9, 4, 5, 2, 11, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {2, 5, 10, 3, 5, 2, 3, 4, 5, 3, 8, 4, -1, -1, -1, -1},
        {5, 10, 2, 5, 2, 4, 4, 2, 0, -1, -1, -1, -1, -1, -1, -1},
        {3, 10, 2, 3, 5, 10, 3, 8, 5, 4, 5, 8, 0, 1, 9, -1},
        {5, 10, 2, 5, 2, 4, 1, 9, 2, 9, 4, 2, -1, -1, -1, -1},
        {8, 4, 5, 8, 5, 3, 3, 5, 1, -1, -1, -1, -1, -1, -1, -1},
        {0, 4, 5, 1, 0, 5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {8, 4, 5, 8, 5, 3, 9, 0, 5, 0, 3, 5, -1, -1, -1, -1},
        {9, 4, 5, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {4, 11, 7, 4, 9, 11, 9, 10, 11, -1, -1, -1, -1, -1, -1, -1},
        {0, 8, 3, 4, 9, 7, 9, 11, 7, 9, 10, 11, -1, -1, -1, -1},
        {1, 10, 11, 1, 11, 4, 1, 4, 0, 7, 4, 11, -1, -1, -1, -1},
        {3, 1, 4, 3, 4, 8, 1, 10, 4, 7, 4, 11, 10, 11, 4, -1},
        {4, 11, 7, 9, 11, 4, 9, 2, 11, 9, 1, 2, -1, -1, -1, -1},
        {9, 7, 4, 9, 11, 7, 9, 1, 11, 2, 11, 1, 0, 8, 3, -1},
        {11, 7, 4, 11, 4, 2, 2, 4, 0, -1, -1, -1, -1, -1, -1, -1},
        {11, 7, 4, 11, 4, 2, 8, 3, 4, 3, 2, 4, -1, -1, -1, -1},
        {2, 9, 10, 2, 7, 9, 2, 3, 7, 7, 4, 9, -1, -1, -1, -1},
        {9, 10, 7, 9, 7, 4, 10, 2, 7, 8, 7, 0, 2, 0, 7, -1},
        {3, 7, 10, 3, 10, 2, 7, 4, 10, 1, 10, 0, 4, 0, 10, -1},
        {1, 10, 2, 8, 7, 4, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {4, 9, 1, 4, 1, 7, 7, 1, 3, -1, -1, -1, -1, -1, -1, -1},
        {4, 9, 1, 4, 1, 7, 0, 8, 1, 8, 7, 1, -1, -1, -1, -1},
        {4, 0, 3, 7, 4, 3, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {4, 8, 7, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {9, 10, 8, 10, 11, 8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {3, 0, 9, 3, 9, 11, 11, 9, 10, -1, -1, -1, -1, -1, -1, -1},
        {0, 1, 10, 0, 10, 8, 8, 10, 11, -1, -1, -1, -1, -1, -1, -1},
        {3, 1, 10, 11, 3, 10, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {1, 2, 11, 1, 11, 9, 9, 11, 8, -1, -1, -1, -1, -1, -1, -1},
        {3, 0, 9, 3, 9, 11, 1, 2, 9, 2, 11, 9, -1, -1, -1, -1},
        {0, 2, 11, 8, 0, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {3, 2, 11, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {2, 3, 8, 2, 8, 10, 10, 8, 9, -1, -1, -1, -1, -1, -1, -1},
        {9, 10, 2, 0, 9, 2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {2, 3, 8, 2, 8, 10, 0, 1, 8, 1, 10, 8, -1, -1, -1, -1},
        {1, 10, 2, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {1, 3, 8, 9, 1, 8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {0, 9, 1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {0, 3, 8, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1},
        {-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1}
};



constant bool pipelineHasColour [[function_constant(0)]];
constant bool packedBuffer [[function_constant(1)]];
constant bool unpackedBuffer [[function_constant(2)]];

uint rand_xorshift(uint rng_state){
    rng_state ^= (rng_state << 13);
    rng_state ^= (rng_state >> 17);
    rng_state ^= (rng_state << 5);
    return rng_state;
}


struct Vertex {
    simd_packed_float3 positions;
    simd_packed_float3 normals;
    simd_packed_float2 tex;
};






struct VertexOutput {
    float4 position [[position]];
    float4 colour;
    float3 localPos;
    float4 normal;
    float2 tex;
};


struct VertexInput {
    float3 position [[attribute(positionAttribute)]];
    float3 normal [[attribute(normalAttribute)]];
    float2 tex [[attribute(textureAttribute)]];
    
};










constant uint max_triangle_perMeshlet = 512;
constant uint max_vertices_perMeshlet = 255;
constant uint vertexStride = 3 + 3 + 2;

//struct meshletData {
//    meshlet meshlets[32];
//    simd_float4 colour[32];
//    uint instanceId[32];
//};


struct PrimOut {
    simd_float4 meshletColour;
};

struct fragmentIn {
    VertexOutput v;
    PrimOut p;
};


static float3 hue2rgb(float hue) {
    hue = fract(hue); //only use fractional part of hue, making it loop
    float r = abs(hue * 6 - 3) - 1; //red
    float g = 2 - abs(hue * 6 - 2); //green
    float b = 2 - abs(hue * 6 - 4); //blue
    float3 rgb = float3(r,g,b); //combine components
    rgb = saturate(rgb); //clamp between 0 and 1
    return rgb;
}



fragment float4 render_meshlets_fragment(fragmentIn in [[stage_in]]
                                         ){
    
    return in.p.meshletColour;
    
}



[[stitchable]] float sin_a(const float a, const float b, const float c){
    return sin(a);
}

[[stitchable]] float cos_a(const float a, const float b, const float c){
    return cos(a);
}

[[stitchable]] float tan_a(const float a, const float b, const float c){
    return tan(a);
}

[[stitchable]] float divide_2(const float a, const float b, const float c){
    return a/2;
}

[[stitchable]] float divide_3(const float a, const float b, const float c){
    return a/3;
}

[[stitchable]] float divide_4(const float a, const float b, const float c){
    return a/4;
}

[[stitchable]] float divide_5(const float a, const float b, const float c){
    return a/5;
}

[[stitchable]] float divide_6(const float a, const float b, const float c){
    return a/6;
}

[[stitchable]] float divide_7(const float a, const float b, const float c){
    return a/7;
}

[[stitchable]] float divide_8(const float a, const float b, const float c){
    return a/8;
}

[[stitchable]] float divide_9(const float a, const float b, const float c){
    return a/9;
}

[[stitchable]] float passFirstVariableThrough(float a, float b, float c){
    return a;
}

[[stitchable]] float add(float a, float b, float c){
    return a+b;
}

[[stitchable]] float minus(float a, float b, float c){
    return a - b;
}

[[stitchable]] float times2(const float a, const float b, const float c){
    return a*2;
}


[[stitchable]] float square(const float a, const float b, const float c){
    return a*a;
}

[[stitchable]] float divide(const float a, const float b, const float c){
    return a / b;
}

[[stitchable]] float multiply(const float a, const float b, const float c){
    return a*b;
}

[[stitchable]] float multiply_abc(const float a, const float b, const float c){
    return a*b*c;
}

[[visible]] float final(const float a,const float b, const float c);





struct pointOutput {
    simd_float4 position [[position]];
    float pointSize [[point_size]];
};

struct pointData {
    simd_float4 position;
    float size;
    simd_float4x4 PVM;
    simd_float4 colour;
    float domainLength;
};


struct pointFragmentIn {
    pointOutput vertices;
    PrimOut colour;
};

using pointMesh = metal::mesh<pointOutput, PrimOut, 1, max_triangle_perMeshlet, metal::topology::point>;

[[object]] void object_shader_iso_surface(constant simd_float4x4* frameTransformBuffers [[buffer(0)]],
                                          constant uint& frameIndex [[buffer(1)]],
                                          constant simd_float3& minGrid [[buffer(2)]],
                                          constant float& voxelHalfLength [[buffer(3)]],
                                          constant float& voxelLength [[buffer(4)]],
                                          constant float& equation_constant [[buffer(5)]],
                                          constant float& pointSizeOffset [[buffer(6)]],
                                          object_data pointData& payload [[payload]],
                                          mesh_grid_properties mgp,
                                          uint3 tgig [[threadgroup_position_in_grid]],
                                          uint tid [[thread_index_in_threadgroup]]

                                          ){
    
    
    //threadgroup float result[10 * 21];
    
    float centreZ = tgig.z * voxelLength + voxelHalfLength + minGrid.z;
    float centreX = tgig.x * voxelLength + voxelHalfLength + minGrid.x;
    float centreY = tgig.y * voxelLength + voxelHalfLength + minGrid.y;

    float z = final(centreX,centreY,0) + equation_constant;
    payload.position = simd_float4(centreX, centreY, z ,1) ;

    payload.PVM = frameTransformBuffers[0] * frameTransformBuffers[1];
    payload.size = clamp(5 + pointSizeOffset,1.f,10.f);
    mgp.set_threadgroups_per_grid(uint3(1,1,1));
    
   
    
    
}


[[mesh]] void mesh_shader_iso_surface(pointMesh output,
                                      const object_data pointData& payload [[payload]],
                                      uint tid [[threadgroup_position_in_grid]],
                                      constant simd_float4& pointColour [[buffer(0)]]
                                      ){
    
    
   
    
    pointOutput v;
    //float c = abs(payload.position[tid].z) / payload.domainLength;
    v.pointSize = payload.size;
    //v.position = payload.PVM * payload.position[tid];
    v.position = payload.PVM * payload.position;
    output.set_vertex(0, v);
    output.set_index(0, 0);
    
    output.set_primitive_count(1);

    output.set_primitive(0, PrimOut{pointColour});
}
                                          

struct isoSurface_FragmentOutput {
    float4 colour [[color(0)]];
    float depth [[color(1)]];
};

isoSurface_FragmentOutput fragment fragment_shader_iso_surface(pointFragmentIn in [[stage_in]]){
    float depth = in.vertices.position.z;
    float4 colour = in.colour.meshletColour;
    return isoSurface_FragmentOutput{colour,depth};
}





constant simd_float3 voxelOffsets[8] = {
    simd_float3(-0.5,-0.5,0.5),
    simd_float3(-0.5,-0.5,-0.5),
    
    simd_float3(0.5,-0.5,0.5),
    simd_float3(0.5,-0.5,-0.5),
    
    simd_float3(-0.5,0.5,0.5),
    simd_float3(-0.5,0.5,-0.5),
    
    simd_float3(0.5,0.5,0.5),
    simd_float3(0.5,0.5,-0.5)
    

    

};


inline array<simd_float3, 8> getVoxelVertices(simd_float3 centre, float voxelHalfLength){
    
    array<simd_float3,8> vertices;
    // bottom edges
    vertices[0] = centre + simd_float3(-voxelHalfLength, -voxelHalfLength, -voxelHalfLength);
    vertices[1] = centre + simd_float3(voxelHalfLength, -voxelHalfLength, -voxelHalfLength);
    vertices[2] = centre + simd_float3(voxelHalfLength, -voxelHalfLength, voxelHalfLength);
    vertices[3] = centre + simd_float3(-voxelHalfLength, -voxelHalfLength, voxelHalfLength);
    
    vertices[4] = vertices[0];
    vertices[5] = vertices[1];
    vertices[6] = vertices[2];
    vertices[7] = vertices[3];
    
    for(uint i = 4; i != 8; i++){
        vertices[i].y += ( 2 * voxelHalfLength);
    }
    
    return vertices;
}

inline simd_float3 interpolateAlongEdges(simd_float3 e0, simd_float3 e1, float v0, float v1, float isoSurfaceValue){
    float t = abs((isoSurfaceValue - v0)) / abs((v1 - v0));
    return e0 + t * (e1 - e0);
}

using voxelMesh = metal::mesh<pointOutput, PrimOut, 64, 64, metal::topology::point>;



using isoSurfaceTriangles = metal::mesh<VertexOutput, PrimOut, 15, 5, metal::topology::triangle>;
struct voxelsPayload {
    simd_float3 voxel[8];
    simd_float3 colour;
    simd_float4x4 PVM;
};

// we can have a max of 5 * 3 vertices
struct triangulateIsoSurfacePayload {
    simd_float3 vertices[15];
    simd_float4x4 PVM;
    uint triangleCount;
};


[[object]] void object_shader_2d_surface_triangulated(
                                                      
                                                      constant simd_float4x4* frameTransformBuffers [[buffer(0)]],
                                                      constant uint& frameIndex [[buffer(1)]],
                                                      constant simd_float3& minGrid [[buffer(2)]],
                                                      constant float& voxelHalfLength [[buffer(3)]],
                                                      constant float& voxelLength [[buffer(4)]],
                                                      constant float& equation_constant [[buffer(5)]],
                                                      object_data triangulateIsoSurfacePayload& payload [[payload]],
                                                      mesh_grid_properties mgp,
                                                      uint3 tgig [[threadgroup_position_in_grid]],
                                                      uint tid [[thread_index_in_threadgroup]]
                            

){
    
    float centreZ = tgig.z * voxelLength + voxelHalfLength + minGrid.z;
    float centreX = tgig.x * voxelLength + voxelHalfLength + minGrid.x;
    float centreY = tgig.y * voxelLength + voxelHalfLength + minGrid.y;
    simd_float3 centre{centreX,centreY,centreZ};
    array<simd_float3,8> voxelVertices = getVoxelVertices(centre, voxelHalfLength);
    // put all the zs into an array
    array<float,8> voxelValues;
    for(uint i = 0; i != 8; i++){
        voxelValues[i] = voxelVertices[i].z - final(voxelVertices[i].x, voxelVertices[i].y, voxelVertices[i].z) + equation_constant;
    }
    // get the voxelIndex
    //float radius = 1;
    int voxelIndex = 0;
    int current_operator = 1;
    float isoLevel = 0;
    for(uint i = 0; i != 8; i++){
        if(voxelValues[i] < isoLevel){
            voxelIndex |= current_operator;
        }
        current_operator *= 2;
    }
    array<int,16> edges;
    for(uint i = 0; i != 16; i++){
        edges[i] = triTable[voxelIndex][i];
    }
    
    // now we have the edges we need to find the edge connections
    // every non -1 value is an edge and indicates an edge connection
    uint currentOffsetIntoPayloadVertices = 0;
    uint triangleCount = 0;
    for(uint i = 0; i <= 15; i+=3){
        // if the first edge is -1 then we can skip this iteration as this won't be a valid edge
        if(edges[i] == -1){
            continue;
        }
        else{
            triangleCount++;
            array<int,2> e00;
            e00[0] = edgeConnections[edges[i]][0];
            e00[1] = edgeConnections[edges[i]][1];
            // get the voxelValue of each end of the edge
            float e00v0 = voxelValues[e00[0]];
            float e00v1 = voxelValues[e00[1]];
            simd_float3 e00p0 = voxelVertices[e00[0]];
            simd_float3 e00p1 = voxelVertices[e00[1]];
            // get the interpolated point along this edge
            simd_float3 p0 = interpolateAlongEdges(e00p0, e00p1, e00v0, e00v1, isoLevel);
            payload.vertices[currentOffsetIntoPayloadVertices++] = p0;
            
            
            array<int,2> e01;
            e01[0] = edgeConnections[edges[i + 1]][0];
            e01[1] = edgeConnections[edges[i + 1]][1];
            float e01v0 = voxelValues[e01[0]];
            float e01v1 = voxelValues[e01[1]];
            simd_float3 e01p0 = voxelVertices[e01[0]];
            simd_float3 e01p1 = voxelVertices[e01[1]];
            simd_float3 p1 = interpolateAlongEdges(e01p0, e01p1, e01v0, e01v1, isoLevel);
            payload.vertices[currentOffsetIntoPayloadVertices++] = p1;
            
            array<int,2> e11;
            e11[0] = edgeConnections[edges[i + 2]][0];
            e11[1] = edgeConnections[edges[i + 2]][1];
            float e11v0 = voxelValues[e11[0]];
            float e11v1 = voxelValues[e11[1]];
            simd_float3 e11p0 = voxelVertices[e11[0]];
            simd_float3 e11p1 = voxelVertices[e11[1]];
            simd_float3 p2 = interpolateAlongEdges(e11p0, e11p1, e11v0, e11v1, isoLevel );
            payload.vertices[currentOffsetIntoPayloadVertices++] = p2;
            
        }
    }
    
    
    
    
    payload.triangleCount = triangleCount;
    payload.PVM = frameTransformBuffers[0] * frameTransformBuffers[1];
    
    if(triangleCount != 0){
        mgp.set_threadgroups_per_grid(uint3(1,1,1));

    }
    
    
    
}
                            




[[object]] void object_shader_iso_surface_triangulated(constant simd_float4x4* frameTransformBuffers [[buffer(0)]],
                                                       constant uint& frameIndex [[buffer(1)]],
                                                       constant simd_float3& minGrid [[buffer(2)]],
                                                       constant float& voxelHalfLength [[buffer(3)]],
                                                       constant float& voxelLength [[buffer(4)]],
                                                       constant float& equation_constant [[buffer(5)]],
                                                       constant float& isoLevel [[buffer(6)]],
                                                       object_data triangulateIsoSurfacePayload& payload [[payload]],
                                                       mesh_grid_properties mgp,
                                                       uint3 tgig [[threadgroup_position_in_grid]],
                                                       uint tid [[thread_index_in_threadgroup]]
                                                       ){
    
    
    // test equation is z = 0
   
    

    float centreZ = tgig.z * voxelLength + voxelHalfLength + minGrid.z;
    float centreX = tgig.x * voxelLength + voxelHalfLength + minGrid.x;
    float centreY = tgig.y * voxelLength + voxelHalfLength + minGrid.y;
    simd_float3 centre{centreX,centreY,centreZ};
    array<simd_float3,8> voxelVertices = getVoxelVertices(centre, voxelHalfLength);
    // put all the zs into an array
    array<float,8> voxelValues;
    for(uint i = 0; i != 8; i++){
        voxelValues[i] = final(voxelVertices[i].x, voxelVertices[i].y, voxelVertices[i].z) + equation_constant;
    }
    // get the voxelIndex
    //float radius = 1;
    int voxelIndex = 0;
    int current_operator = 1;
    for(uint i = 0; i != 8; i++){
        if(voxelValues[i] < isoLevel){
            voxelIndex |= current_operator;
        }
        current_operator *= 2;
    }
    array<int,16> edges;
    for(uint i = 0; i != 16; i++){
        edges[i] = triTable[voxelIndex][i];
    }
    
    // now we have the edges we need to find the edge connections
    // every non -1 value is an edge and indicates an edge connection
    uint currentOffsetIntoPayloadVertices = 0;
    uint triangleCount = 0;
    for(uint i = 0; i <= 15; i+=3){
        // if the first edge is -1 then we can skip this iteration as this won't be a valid edge
        if(edges[i] == -1){
            continue;
        }
        else{
            triangleCount++;
            array<int,2> e00;
            e00[0] = edgeConnections[edges[i]][0];
            e00[1] = edgeConnections[edges[i]][1];
            // get the voxelValue of each end of the edge
            float e00v0 = voxelValues[e00[0]];
            float e00v1 = voxelValues[e00[1]];
            simd_float3 e00p0 = voxelVertices[e00[0]];
            simd_float3 e00p1 = voxelVertices[e00[1]];
            // get the interpolated point along this edge
            simd_float3 p0 = interpolateAlongEdges(e00p0, e00p1, e00v0, e00v1, isoLevel);
            payload.vertices[currentOffsetIntoPayloadVertices++] = p0;
            
            
            array<int,2> e01;
            e01[0] = edgeConnections[edges[i + 1]][0];
            e01[1] = edgeConnections[edges[i + 1]][1];
            float e01v0 = voxelValues[e01[0]];
            float e01v1 = voxelValues[e01[1]];
            simd_float3 e01p0 = voxelVertices[e01[0]];
            simd_float3 e01p1 = voxelVertices[e01[1]];
            simd_float3 p1 = interpolateAlongEdges(e01p0, e01p1, e01v0, e01v1, isoLevel);
            payload.vertices[currentOffsetIntoPayloadVertices++] = p1;
            
            array<int,2> e11;
            e11[0] = edgeConnections[edges[i + 2]][0];
            e11[1] = edgeConnections[edges[i + 2]][1];
            float e11v0 = voxelValues[e11[0]];
            float e11v1 = voxelValues[e11[1]];
            simd_float3 e11p0 = voxelVertices[e11[0]];
            simd_float3 e11p1 = voxelVertices[e11[1]];
            simd_float3 p2 = interpolateAlongEdges(e11p0, e11p1, e11v0, e11v1, isoLevel );
            payload.vertices[currentOffsetIntoPayloadVertices++] = p2;
            
        }
    }
    
    
    
    
    payload.triangleCount = triangleCount;
    payload.PVM = frameTransformBuffers[0] * frameTransformBuffers[1];
    

    

    
    
   
    if(triangleCount != 0){
        mgp.set_threadgroups_per_grid(uint3(1,1,1));

    }
    

        
}
         



[[mesh]] void mesh_shader_iso_surface_triangulated(isoSurfaceTriangles output,
                                                   const object_data triangulateIsoSurfacePayload& payload [[payload]],
                                                   constant simd_float4& isoColour [[buffer(0)]]
                                                   ){
    // tgc is equal to slice size
    
    PrimOut p{isoColour};
    uint indexOffset = 0;
    uint vertexOffset = 0;
    for(uint i = 0; i != payload.triangleCount; i++){
        uint payloadOffset = i * 3;
        VertexOutput out0;
        VertexOutput out1;
        VertexOutput out2;
        simd_float4 p0 = simd_float4(payload.vertices[payloadOffset + 0],1);
        simd_float4 p1 = simd_float4(payload.vertices[payloadOffset + 1],1);
        simd_float4 p2 = simd_float4(payload.vertices[payloadOffset + 2],1);
        out0.position = payload.PVM * p0;
        out1.position = payload.PVM * p1;
        out2.position = payload.PVM * p2;
        output.set_index(indexOffset + 0, indexOffset + 0);
        output.set_index(indexOffset + 1, indexOffset + 1);
        output.set_index(indexOffset + 2, indexOffset + 2);
        
        output.set_vertex(vertexOffset + 0, out0);
        output.set_vertex(vertexOffset + 1, out1);
        output.set_vertex(vertexOffset + 2, out2);
        
        output.set_primitive(i, p);
        indexOffset+=3;
        vertexOffset+=3;
        
    }

    output.set_primitive_count(payload.triangleCount);

    
    // every threadgroup will emit one voxel aka 8 points
}
        

struct Triangle {
    simd_float4 vertices[3];
};

struct isoSurfaceObjecShaderOutput {
    Triangle triangles[5];
    uint triangleCount;
    simd_float4x4 PVM;
    simd_float4 colour;
};



using Voxel = metal::mesh<VertexOutput, PrimOut, 3, 1, metal::topology::triangle>;

inline simd_float4 interpolateEdges(int edges[2], simd_float4 cube[8], int isoValue, int cubeValues[8]){
    simd_float4 v0 = cube[edges[0]];
    simd_float4 v1 = cube[edges[1]];
    int v0Value = cubeValues[edges[0]];
    int v1Value = cubeValues[edges[1]];
    simd_float3 edgeDelta = simd_float3(v1 - v0);
    int valueDelta = abs(v1Value - v0Value);
    
    simd_float3 interpolatesP = (((isoValue - v0Value) / valueDelta) * edgeDelta) + v0.xyz;
    return simd_float4(interpolatesP, 1);
    
}


constant simd_float4 QuadVertices[4] = {
    simd_float4(-1,-1,0,1),
    simd_float4(1,-1,0,1),
    simd_float4(-1,1,0,1),
    simd_float4(1,1,0,1)
};

constant simd_float2 QuadTex[4] = {
    simd_float2(0,0),
    simd_float2(1,0),
    simd_float2(0,1),
    simd_float2(1,1)
};

struct QuadOut {
    simd_float4 pos [[position]];
    simd_float2 tex;
};




vertex QuadOut isoLevel_transparency_vertex_shader(uint vID [[vertex_id]]){
    QuadOut out;
    out.pos = QuadVertices[vID];
    out.tex = QuadTex[vID];
    return out;
    
};


fragment float4 isoLevel_transparency_fragment_shader(QuadOut in [[stage_in]],
                                                      
                                                      constant TextureBuffer* colourLayers [[buffer(0)]],
                                                      constant TextureBuffer* depthLayers [[buffer(1)]],
                                                      constant uint& isoLevel [[buffer(2)]]
                                                      
                                                      
                                                      ){
    constexpr sampler s = sampler(coord::normalized,
                                  address::clamp_to_zero,
                                  filter::nearest);
    
    array<simd_float4,3> colours{simd_float4(1),simd_float4(1),simd_float4(1)};
    array<float,3> depths{1,1,1};
    
    for (uint i = 0; i != isoLevel; i++){
        float depth = depthLayers[i].texture.sample(s, in.tex).r;
        float4 colour = colourLayers[i].texture.sample(s, in.tex);
        for(int i = isoLevel - 1; i >= 0; i--){
            // replace depth
            if(depth < depths[i]){
                float tempDepth = depths[i];
                depths[i] = depth;
                depth = tempDepth;
                float4 tempColour = colours[i];
                colours[i] = colour;
                colour = tempColour;
            }
        }
    }
   
    
    // blend the colours back to front
    
    float3 finalColour = simd_float3(1);

    array<float,3> alphas{colours[0].w,colours[1].w,colours[2].w};
    
    for(uint i = 0; i != isoLevel; i++){
        finalColour = finalColour * (1 - alphas[i]) + colours[i].rgb * alphas[i];
    }
    
    return float4(finalColour,1);
    
    
    
}
