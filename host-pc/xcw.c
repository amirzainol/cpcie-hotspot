// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//This library is free software; you can redistribute it and/or
//modify it under the terms of the GNU Lesser General Public
//License as published by the Free Software Foundation; either
//version 2.1 of the License, or (at your option) any later version.
//
//This library is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//Lesser General Public License for more details.
//
//You should have received a copy of the GNU Lesser General Public
//License along with this library; if not, write to the Free Software
//Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
//
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//
// Author: 			Mohd Amiruddin Zainol (mohd.a.zainol@gmail.com)
// Entity: 			xcw.c
// Version:			1.0
// Description: 	This file is used to write input of datasets
//
// Additional Comments:
//
// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#include <Windows.h>
#include <stdio.h>
#include <stdlib.h>
#include <io.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h> /* Needed only for _O_RDWR definition */
#include <stdint.h>
#include <errno.h>
#include <signal.h>
#include <share.h>
#include <conio.h>
#include <ctype.h>
#include <time.h> // sleep 

#include "cpcie.h"

int fdw0 = 0;
int fdw1 = 0;
static int fh0 = 0;
static int fh1 = 0;
static int fdr = 0;
char *input_file0;
char *input_file1;
int fdw_cmd_stat;
int fdr_cmd_stat;
int filesize_0_w;
int filesize_1_w;
unsigned int written_value;
unsigned int read_value;

int read_addr(int addr);
void allwrite(int fd, unsigned int *buf, int len);
void memread(int fd, unsigned int *buf, int len);
void xillybus_init();
void xillybus_close();
void write_addr(int addr, int value);
int get_filesize0(char *the_file);
int get_filesize1(char *the_file);
void allwritex(int fd, unsigned char *buf, int len);

struct packet 
{ 
	int bytes;  
};

void allwrite(int fd, unsigned int *buf, int len) {
  int sent = 0;
  int rc;

  // allwrite() loops until all data was indeed written, or exits in
  // case of failure, except for EINTR. The way the EINTR condition is
  // handled is the standard way of making sure the process can be suspended
  // with CTRL-Z and then continue running properly.
  while (sent < len) {
    rc = _write(fd, buf + sent, len - sent);
	
    if ((rc < 0) && (errno == EINTR))
      continue;

    if (rc < 0) {
      perror("allwrite() failed to write");
      exit(1);
    }
	
    // The function has no return value, because it always succeeds (or exits
    // instead of returning).
	// The function doesn't expect to reach EOF either.
    if (rc == 0) {
      fprintf(stderr, "Reached write EOF (?!)\n"); 
      exit(1);
    }
 
    sent += rc;
  }
} 

void allwritex(int fd, unsigned char *buf, int len) {
  int sent = 0;
  int rc;

  while (sent < len) {

    rc = _write(fd, buf + sent, len - sent);
	
    if ((rc < 0) && (errno == EINTR))
      continue;

    if (rc < 0) {
      perror("allwrite() failed to write");
      exit(1);
    }
	
    if (rc == 0) {
      fprintf(stderr, "Reached write EOF (?!)\n");
      exit(1);
    }
 
    sent += rc;
  }

} 
void memread(int fd, unsigned int *buf, int len) {
  int received = 0;
  int rc;

  while (received < len) {
    rc = _read(fd, buf + received, len - received);
	
    if ((rc < 0) && (errno == EINTR))
      continue;

    if (rc < 0) {
      perror("memread() failed to read");
      exit(1);
    }
	
    if (rc == 0) {
      fprintf(stderr, "Reached read EOF (?!)\n");
      exit(1);
    }
 
    received += rc;
  }
} 

void xillybus_init()
{
	fdw_cmd_stat = _open("\\\\.\\xillybus_xcw_ctrl", O_WRONLY | _O_BINARY);

	if (fdw_cmd_stat < 0) {
		if (errno == ENODEV)
			fprintf(stderr, "(Maybe fdw_cmd_stat a read-only file?)\n");
			perror("Failed to open devfile fdw_cmd_stat");
			exit(1);
	}

	fdr_cmd_stat = _open("\\\\.\\xillybus_xcw_ctrl", O_RDONLY | _O_BINARY);

	if (fdr_cmd_stat < 0) {
		if (errno == ENODEV)
			fprintf(stderr, "(Maybe fdr_cmd_stat a write-only file?)\n");
			perror("Failed to open devfile fdr_cmd_stat");
			exit(1);
	}

	fdw0 = _open("\\\\.\\xillybus_wr_0", O_WRONLY | _O_BINARY);

	if (fdw0 < 0) {
		if (errno == ENODEV)
			fprintf(stderr, "(Maybe xillybus_write_32 a read-only file?)\n");
			perror("Failed to open devfile");
			exit(1);
	}

	fdw1 = _open("\\\\.\\xillybus_wr_1", O_WRONLY | _O_BINARY);

	if (fdw1 < 0) {
		if (errno == ENODEV)
			fprintf(stderr, "(Maybe xillybus_write_32 a read-only file?)\n");
			perror("Failed to open devfile");
			exit(1);
	}
}

int read_addr(int addr)
{
	if (_lseek(fdr_cmd_stat, addr, SEEK_SET) < 0) {
		perror("Failed to seek (read)");
		exit(1);
	}

	memread(fdr_cmd_stat, &read_value, 4);
	return read_value;
}

void write_addr(int addr, int value)
{
	if (_lseek(fdw_cmd_stat, addr, SEEK_SET) < 0) {
		perror("Failed to seek (write)");
		exit(1);
	}

	written_value = (unsigned int) value;
	allwrite(fdw_cmd_stat, &written_value, 4);
}

void xillybus_close()
{
	_close(fdw0);
	_close(fdw1);
	_close(fdr_cmd_stat);
	_close(fdw_cmd_stat);
}

int get_filesize0(char *the_file) {

	int filesize;

	if( _sopen_s( &fh0, the_file, _O_RDONLY | _O_BINARY, _SH_DENYNO, 0 ) )
	{
		perror( "open failed on input file" );
		exit( 1 );
	}
	filesize = _filelength(fh0);

	return filesize;
}

int get_filesize1(char *the_file) {

	int filesize;

	if( _sopen_s( &fh1, the_file, _O_RDONLY | _O_BINARY, _SH_DENYNO, 0 ) )
	{
		perror( "open failed on input file" );
		exit( 1 );
	}
	filesize = _filelength(fh1);

	return filesize;
}

DWORD WINAPI hostpc_tx_file0(LPVOID arg)
{
	unsigned char *buf;
	int donebytes;
	int rc=0;

	buf = (char *) malloc(filesize_0_w);
	donebytes = 0;

	while (1) {

		rc = _read(fh0, buf, filesize_0_w);
		rc += 4; // tupple of 4
	  
		if ((rc < 0) && (errno == EINTR))
			continue;
		
		if (rc < 0) {
			perror("allread() failed to read");
			exit(1);
		}
		
		if (rc == 0) {
			fprintf(stderr, "Reached read EOF.\n");
			exit(0);
		}

		allwritex(fdw0, buf, rc);
		break;
	}

	_close(fh0);
	free(buf);

	return 0;
}

DWORD WINAPI hostpc_tx_file1(LPVOID arg)
{
	unsigned char *buf;
	int donebytes;
	int rc=0;

	buf = (char *) malloc(filesize_1_w);
	donebytes = 0;

	while (1) {

		rc = _read(fh1, buf, filesize_1_w);
		rc += 4; // tupple of 4
	  
		if ((rc < 0) && (errno == EINTR))
			continue;
		
		if (rc < 0) {
			perror("allread() failed to read");
			exit(1);
		}
		
		if (rc == 0) {
			fprintf(stderr, "Reached read EOF.\n");
			exit(0);
		}

		allwritex(fdw1, buf, rc);
		break;
	}

	_close(fh1);
	free(buf);

	return 0;
}

void errorprint(char *what, DWORD dw) {
  LPVOID lpMsgBuf;
  
  FormatMessage(
		FORMAT_MESSAGE_ALLOCATE_BUFFER | 
		FORMAT_MESSAGE_FROM_SYSTEM |
		FORMAT_MESSAGE_IGNORE_INSERTS,
		NULL,
		dw,
		MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT),
		(LPTSTR) &lpMsgBuf,
		0, NULL );
  
  
  fprintf(stderr, "%s: Error=%08x:\n%s\n",
	  what, dw, lpMsgBuf); 
  
  LocalFree(lpMsgBuf);
}

int __cdecl main(int argc, char *argv[]) {

	//~~~~~~ File ~~~~~~~//
	//int filesize_0_w;
	//int filesize_1_w;
	//int filesize_01_r;

	//~~~~ write file to host pc ~~~~//
	/*
    unsigned char buf;
	int rc=0;
	int received = 0;
	char *ptr02;
	FILE *pfile;
	int donebytes;
	*/
	int HLS_stat = 0;
	int XCR_stat = 0;
	int XCW_stat = 0;

	int i=0;
	int ten = 10;
	unsigned int RD0_stat=0;

	char file_in[16] = "sim_X_00XX.bin";

	struct packet fifowrite0;
	struct packet fifowrite1;

  	HANDLE Handle_Of_Thread_0 = 0;       // variable to hold handle of Thread 0
	HANDLE Handle_Of_Thread_1 = 0;       // variable to hold handle of Thread 1 
 	HANDLE Array_Of_Thread_Handles[2];   // Array to store thread handles 

	//~~~~~~~ Kernel Hotspot ~~~~~~~~~//
	int t_rep = 0; // total repetition

	xillybus_init();

	write_addr(ADDR_XCW_STAT, INIT);
	
	input_file0 = (argv[1]);
	input_file1 = (argv[2]);
	t_rep = atoi(argv[3]);	

	write_addr(ADDR_XCW_TREP, t_rep); // total repetition

	for (i=0; i<t_rep; i++) {

		write_addr(ADDR_HLS_RESETN, START);

		if (i == 0) {
			// check if the first loop is 0
			// if yes, then use temp_1024.bin file
			filesize_0_w = get_filesize0(input_file0);
		}
		else {
			// if not, use the output result from HLS

			if (i < 10) {
				file_in[9] = (i - ten*0) + '0';
				file_in[8] = '0';
				file_in[7] = '0';
				file_in[4] = 'U'; 
			}
			else if (i < 20) {
				file_in[9] = (i - ten*1) + '0';
				file_in[8] = '1';
				file_in[7] = '0';
				file_in[4] = 'U'; 
			}
			else if (i < 30) {
				file_in[9] = (i - ten*2) + '0';
				file_in[8] = '2';
				file_in[7] = '0';
				file_in[4] = 'U'; 
			}
			else if (i < 40) {
				file_in[9] = (i - ten*3) + '0';
				file_in[8] = '3';
				file_in[7] = '0';
				file_in[4] = 'U'; 
			}
			else if (i < 50) {
				file_in[9] = (i - ten*4) + '0';
				file_in[8] = '4';
				file_in[7] = '0';
				file_in[4] = 'U'; 
			}
			else if (i < 60) {
				file_in[9] = (i - ten*5) + '0';
				file_in[8] = '5';
				file_in[7] = '0';
				file_in[4] = 'U'; 
			}
			else if (i < 70) {
				file_in[9] = (i - ten*6) + '0';
				file_in[8] = '6';
				file_in[7] = '0';
				file_in[4] = 'U'; 
			}
			else if (i < 80) {
				file_in[9] = (i - ten*7) + '0';
				file_in[8] = '7';
				file_in[7] = '0';
				file_in[4] = 'U'; 
			}
			else if (i < 90) {
				file_in[9] = (i - ten*8) + '0';
				file_in[8] = '8';
				file_in[7] = '0';
				file_in[4] = 'U'; 
			}
			else if (i < 100) {
				file_in[9] = (i - ten*9) + '0';
				file_in[8] = '9';
				file_in[7] = '0';
				file_in[4] = 'U'; 
			}
			else if (i < 110) {
				file_in[9] = (i - ten*10) + '0';
				file_in[8] = '0';
				file_in[7] = '1';
				file_in[4] = 'U'; 
			}

			filesize_0_w = get_filesize0(file_in);
		}
		
		filesize_1_w = get_filesize1(input_file1);

		write_addr(ADDR_RD0, filesize_0_w); // write the file size to be read, it can be filesize_0_w or _1_w

		write_addr(ADDR_XCW_STAT, READY);

		XCR_stat = read_addr(ADDR_XCR_STAT);
		while(!XCR_stat)
		{
			XCR_stat = read_addr(ADDR_XCR_STAT);
		}

		write_addr(ADDR_HLS_CMD, START);

		// Create thread 0: Write file0
		Handle_Of_Thread_0 = CreateThread(NULL, 0, hostpc_tx_file0, &fifowrite0, 0, NULL);
		if (Handle_Of_Thread_0 == NULL) {
		errorprint("Failed to create thread 0\n", GetLastError());
		exit(1);
		}

		// Create thread 1: Write file1
		Handle_Of_Thread_1 = CreateThread(NULL, 0, hostpc_tx_file1, &fifowrite1, 0, NULL);
		if (Handle_Of_Thread_1 == NULL) {
		errorprint("Failed to create thread 1\n", GetLastError());
		exit(1);
		}

		// Store Thread handles in Array of Thread Handles as per the requirement of WaitForMultipleObjects() 
		Array_Of_Thread_Handles[0] = Handle_Of_Thread_0;
		Array_Of_Thread_Handles[1] = Handle_Of_Thread_1;

		// Wait until all threads have terminated.
		//WaitForMultipleObjects(2, Array_Of_Thread_Handles, TRUE, INFINITE); // not using this
		WaitForSingleObject(Array_Of_Thread_Handles[0], INFINITE);
		WaitForSingleObject(Array_Of_Thread_Handles[1], INFINITE);

		// Close all thread handles upon completion.
		CloseHandle(Handle_Of_Thread_0);
		CloseHandle(Handle_Of_Thread_1);

		write_addr(ADDR_XCW_STAT, DONE);

		XCR_stat = read_addr(ADDR_XCR_STAT);
		while(XCR_stat)
		{
			XCR_stat = read_addr(ADDR_XCR_STAT);
		}

		write_addr(ADDR_HLS_CMD, STOP);
		write_addr(ADDR_HLS_RESETN, STOP);

		Sleep(1);

	} // end of 'for loop' (t_rep)

	xillybus_close();
	return 0;
}