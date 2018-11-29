
#include "wav.h"


struct wav * wav_read(char *file_name) 
{
	struct wav * w = malloc(sizeof(struct wav));

	FILE* wav_file;
	if (!file_name) {
		printf("Filename cannot be NULL\n");
		return NULL;
	}

	if ((wav_file = _FOPEN_(file_name,"r")) == NULL) {
		printf("Error opening file");
	}

	w->header = (struct wav_header*)malloc(sizeof(struct wav_header));
	if (w->header == NULL) {
		printf("Unable to allocate memory\n");
		_FCLOSE_(wav_file);
		return NULL;
	}

	if (_FREAD_(w->header, sizeof(struct wav_header), 1, wav_file) < 1) {
		printf("Broken wav header");
		free(w);
		_FCLOSE_(wav_file);
		return NULL;
	}

	if (strncmp(w->header->chunk_id, "RIFF", 4) || strncmp(w->header->format, "WAVE", 4)) {
		printf("Not a wav file\n");
		free(w);
		_FCLOSE_(wav_file);
		return NULL;
	}

	if (w->header->audio_format != 1) {
		printf("Only PCM encoding supported");
		free(w);
		_FCLOSE_(wav_file);
		return NULL;
	}
	
	w->samples = malloc(w->header->datachunk_size);

	if (!w->samples) {
		printf("Unable to allocate memory for samples\n");
		free(w);
		_FCLOSE_(wav_file);
		return NULL;
	}

	if (_FREAD_(w->samples, 1, w->header->datachunk_size, wav_file) < w->header->datachunk_size) {
		printf("Unable to load samples");
		free(w->samples);
		free(w);
		w = NULL;
	}
	_FCLOSE_(wav_file);
	return w;
}


uint32_t wav_write(char *file_name, struct wav *w)
{
	FILE *wav_file;
	if (!file_name) {
		printf("Filename cannot be NULL\n");
		return -1;
	}
	
	if (!w->samples) {
		printf("Samples buffer cannot be NULL\n");
		return -1;
	}
	
	if ((wav_file = _FOPEN_(file_name, "w")) == NULL) {
		printf("Error creating file\n");
		return -1;
	}
	
	if (_FWRITE_(w->header, sizeof(struct wav_header), 1, wav_file) < 1) {
		printf("Error writing header");
		_FCLOSE_(wav_file);
		return -1;
	}
	
	if (_FWRITE_(w->samples, 1, w->header->datachunk_size, wav_file) < w->header->datachunk_size) {
		printf("Error writing samples");
		_FCLOSE_(wav_file);
		return -1;
	}
		
	_FCLOSE_(wav_file);
	return 0;
}


struct wav *wav_new(uint32_t sample_number, uint16_t num_channels, uint32_t sample_rate, uint8_t bps)
{
	if((bps != 8) && (bps !=16)) {
		return NULL;
	}

	struct wav *w = malloc (sizeof(struct wav));
	w->header = malloc(sizeof(struct wav_header));
	uint32_t datachunk_size = sample_number * num_channels * (bps/8);
	w->samples = malloc(datachunk_size);

	memcpy(w->header->chunk_id, "RIFF", 4);
	w->header->chunk_size =  36 + datachunk_size;
	memcpy(w->header->format, "WAVE", 4);
	
	memcpy(w->header->fmtchunk_id, "fmt ", 4);
	w->header->fmtchunk_size = 16;
	w->header->audio_format = 1;
	w->header->num_channels = num_channels;
	w->header->sample_rate = sample_rate;
	w->header->byte_rate = sample_rate * num_channels * (bps/8);
	w->header->block_align = num_channels * (bps/8);
	w->header->bps = bps;
	
	memcpy(w->header->datachunk_id, "data", 4);
	w->header->datachunk_size = datachunk_size;
	
	return w;
}

void wav_free(struct wav *w)
{
	free(w->samples);
	free(w->header);
	free(w);
	w = NULL;
}


uint32_t wav_sample_count(struct wav* w)
{
	return w->header->datachunk_size/w->header->block_align;
}

void wav_print_info(struct wav * w)
{
	printf("No. of channels: %d\n", w->header->num_channels);
	printf("Sample rate: %d\n", w->header->sample_rate);
	printf("Bit rate: %dkbps\n", w->header->byte_rate*8 / 1000);
	printf("Byte rate: %d\n", w->header->byte_rate);
	printf("Bits per sample: %d\n\n", w->header->bps);
	printf("length [s]: %f s\n\n", (float)w->header->datachunk_size/w->header->byte_rate);

	//print_sample(read_sample(0, w));
	//print_sample(read_sample(1, w));
	//print_sample(read_sample(2, w));
	//print_sample(read_sample(3, w));
}


