#include <stdio.h>
#include <string.h>

#define BUFFER_SIZE 64

// Version corregida: usa strncpy con limite explicito.
// El buffer nunca puede ser desbordado sin importar el tamanio del input.
void safe(char *input) {
    char buffer[BUFFER_SIZE];
    strncpy(buffer, input, BUFFER_SIZE - 1); // copia maximo BUFFER_SIZE-1 bytes
    buffer[BUFFER_SIZE - 1] = '\0';          // garantiza null terminator
    printf("Buffer contiene: %s\n", buffer);
}

int main(int argc, char *argv[]) {
    if (argc < 2) {
        printf("Uso: %s <input>\n", argv[0]);
        return 1;
    }

    safe(argv[1]);

    printf("Programa termino normalmente.\n");
    return 0;
}
