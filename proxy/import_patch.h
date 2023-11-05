// Tihiy Import Patcher Header

#include <Windows.h>
#include <delayimp.h>

class ImportPatch
{
public:
	static BOOL WINAPI ChangeImportedAddress(HMODULE hModule, LPCSTR modulename, FARPROC origfunc, FARPROC newfunc);
};
