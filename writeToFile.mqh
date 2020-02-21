void writeToFile(string file, string msg)
{
   int file_handle = FileOpen(file, FILE_WRITE|FILE_READ);
   if(file_handle == INVALID_HANDLE) return;

   FileSeek(file_handle, 0, SEEK_END);
   FileWrite(file_handle, TimeToString(TimeLocal(), TIME_DATE|TIME_MINUTES|TIME_SECONDS), msg);
   FileFlush(file_handle);
   FileClose(file_handle);
}