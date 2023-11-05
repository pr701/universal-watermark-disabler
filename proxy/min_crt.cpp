#include <string.h>
#include <Windows.h>

#pragma warning(disable:4273)
#pragma function(memcpy)
#pragma function(memset)
#pragma function(memcmp)

void* malloc(size_t size)
{
	return HeapAlloc(GetProcessHeap(), 0, size);
}

void* calloc(size_t count, size_t size)
{
	return HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, count * size);
}

void free(void* ptr)
{
	if (ptr)
		HeapFree(GetProcessHeap(), 0, ptr);
}

void* realloc(void* ptr, size_t size)
{
	if (ptr)
		return HeapReAlloc(GetProcessHeap(), 0, ptr, size);
	else 
		return HeapAlloc(GetProcessHeap(), 0, size);
}

void* recalloc(void* ptr, size_t size)
{
	if (ptr)
		return HeapReAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, ptr, size);
	else
		return HeapAlloc(GetProcessHeap(), HEAP_ZERO_MEMORY, size);
}

void* operator new(size_t size)
{
	return malloc(size);
}

void operator delete(void* ptr)
{
	free(ptr);
}

void* operator new[](size_t size)
{
	return malloc(size);
}

void operator delete[](void* ptr)
{
	free(ptr);
}

void *memcpy(void *dst, const void *src, size_t n)
{
	const char *p = (const char*)src;
	char *q = (char*)dst;
#if defined(__i386__)
	size_t nl = n >> 2;
	asm volatile ("cld ; rep ; movsl ; movl %3,%0 ; rep ; movsb":"+c" (nl),
		      "+S"(p), "+D"(q)
		      :"r"(n & 3));
#elif defined(__x86_64__)
	size_t nq = n >> 3;
	asm volatile ("cld ; rep ; movsq ; movl %3,%%ecx ; rep ; movsb":"+c"
		      (nq), "+S"(p), "+D"(q)
		      :"r"((uint32_t) (n & 7)));
#else
	while (n--) {
		*q++ = *p++;
	}
#endif

	return dst;
}

void *memset(void *dst, int c, size_t n)
{
	char *q = (char*)dst;

#if defined(__i386__)
	size_t nl = n >> 2;
	asm volatile ("cld ; rep ; stosl ; movl %3,%0 ; rep ; stosb"
		      : "+c" (nl), "+D" (q)
		      : "a" ((unsigned char)c * 0x01010101U), "r" (n & 3));
#elif defined(__x86_64__)
	size_t nq = n >> 3;
	asm volatile ("cld ; rep ; stosq ; movl %3,%%ecx ; rep ; stosb"
		      :"+c" (nq), "+D" (q)
		      : "a" ((unsigned char)c * 0x0101010101010101U),
			"r" ((uint32_t) n & 7));
#else
	while (n--) {
		*q++ = c;
	}
#endif

	return dst;
}

int memcmp(const void *s1, const void *s2, size_t n)
{
        const unsigned char *c1 = (const unsigned char*)s1, *c2 = (const unsigned char*)s2;
        int d = 0;

        while (n--) {
                d = (int)*c1++ - (int)*c2++;
                if (d)
                        break;
        }

        return d;
}
