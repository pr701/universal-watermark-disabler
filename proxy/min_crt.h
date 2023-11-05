// Minimal CRT

void* malloc(size_t size);
void* calloc(size_t count, size_t size);
void free(void* ptr);
void* realloc(void* ptr, size_t size);
void* recalloc(void* ptr, size_t size);
void* operator new(size_t size);
void operator delete(void* ptr);
void* operator new[](size_t size);
void operator delete[](void* ptr);
void *memcpy(void *dst, const void *src, size_t n);
void *memset(void *dst, int c, size_t n);
int memcmp(const void *s1, const void *s2, size_t n);

