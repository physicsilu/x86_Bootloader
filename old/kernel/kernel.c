// void print(const char* str) {
//     while (*str) {
//         __asm__ volatile (
//             "movb $0x0E, %%ah;"
//             "movb %0, %%al;"
//             "int $0x10"
//             :
//             : "r"(*str)
//             : "ah", "al"
//         );
//         str++;
//     }
// }

// // Entry point the bootloader jumps to
// void _start() {
//     print("Welcome to the Kernel!");
//     while (1);
// }


// Pointer to the VGA video memory
volatile unsigned char* vga_buffer = (unsigned char*)0xB8000;
int vga_index = 0;

// VGA color attributes
// Bits 7-4: Background color, Bits 3-0: Foreground color
// 0x0F is White on Black
#define WHITE_ON_BLACK 0x0F

void print(const char* str) {
    while (*str) {
        // Place the character byte
        vga_buffer[vga_index] = *str;
        // Place the attribute byte
        vga_buffer[vga_index + 1] = WHITE_ON_BLACK;
        
        str++;
        vga_index += 2; // Move to the next character cell
    }
}

// Entry point the bootloader jumps to
void _start() {
    // Clear the screen by writing spaces with our attribute
    for (int i = 0; i < 80 * 25 * 2; i += 2) {
        vga_buffer[i] = ' ';
        vga_buffer[i+1] = WHITE_ON_BLACK;
    }
    
    print("Welcome to the 32-bit Kernel!");
    
    // Hang forever
    while (1);
}