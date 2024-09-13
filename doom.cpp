#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>
#include <iostream>

// Function to render the HUD
void renderHUD(SDL_Renderer* renderer, TTF_Font* font) {
    // Set text color to white
    SDL_Color textColor = {255, 255, 255, 255};

    // Create surface and texture for the text
    SDL_Surface* surfaceMessage = TTF_RenderText_Solid(font, "Health: 100", textColor);
    if (!surfaceMessage) {
        std::cerr << "TTF_RenderText_Solid Error: " << TTF_GetError() << std::endl;
        return;
    }

    SDL_Texture* message = SDL_CreateTextureFromSurface(renderer, surfaceMessage);
    if (!message) {
        std::cerr << "SDL_CreateTextureFromSurface Error: " << SDL_GetError() << std::endl;
        SDL_FreeSurface(surfaceMessage);
        return;
    }

    // Define where to render the text
    SDL_Rect messageRect;
    messageRect.x = 10;
    messageRect.y = 10;
    messageRect.w = surfaceMessage->w;
    messageRect.h = surfaceMessage->h;

    // Render the text
    SDL_RenderCopy(renderer, message, NULL, &messageRect);

    // Clean up
    SDL_FreeSurface(surfaceMessage);
    SDL_DestroyTexture(message);
}

int main(int argc, char* argv[]) {
    // Initialize SDL Video
    if (SDL_Init(SDL_INIT_VIDEO) != 0) {
        std::cerr << "SDL_Init Error: " << SDL_GetError() << std::endl;
        return 1;
    }

    // Initialize TTF
    if (TTF_Init() == -1) {
        std::cerr << "TTF_Init Error: " << TTF_GetError() << std::endl;
        SDL_Quit();
        return 1;
    }

    // Create an SDL window
    SDL_Window* window = SDL_CreateWindow("SDL2 HUD Example",
                                          SDL_WINDOWPOS_CENTERED,
                                          SDL_WINDOWPOS_CENTERED,
                                          800, 600,
                                          SDL_WINDOW_SHOWN);
    if (!window) {
        std::cerr << "SDL_CreateWindow Error: " << SDL_GetError() << std::endl;
        TTF_Quit();
        SDL_Quit();
        return 1;
    }

    // Create an SDL renderer
    SDL_Renderer* renderer = SDL_CreateRenderer(window, -1,
                                                SDL_RENDERER_ACCELERATED | SDL_RENDERER_PRESENTVSYNC);
    if (!renderer) {
        std::cerr << "SDL_CreateRenderer Error: " << SDL_GetError() << std::endl;
        SDL_DestroyWindow(window);
        TTF_Quit();
        SDL_Quit();
        return 1;
    }

    // Load a font
    TTF_Font* font = TTF_OpenFont("path/to/font.ttf", 24);
    if (!font) {
        std::cerr << "TTF_OpenFont Error: " << TTF_GetError() << std::endl;
        SDL_DestroyRenderer(renderer);
        SDL_DestroyWindow(window);
        TTF_Quit();
        SDL_Quit();
        return 1;
    }

    // Main loop flag
    bool running = true;

    // Event handler
    SDL_Event event;

    // Main application loop
    while (running) {
        // Handle events
        while (SDL_PollEvent(&event)) {
            // User requests quit
            if (event.type == SDL_QUIT) {
                running = false;
            }
            // Handle additional events (keyboard, mouse, etc.) here
        }

        // Clear the renderer
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255); // Black background
        SDL_RenderClear(renderer);

        // Render the HUD
        renderHUD(renderer, font);

        // Update the screen
        SDL_RenderPresent(renderer);
    }

    // Clean up resources
    TTF_CloseFont(font);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);

    // Quit SDL subsystems
    TTF_Quit();
    SDL_Quit();

    return 0;
}
