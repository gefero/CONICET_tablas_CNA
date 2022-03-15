
path <- 'https://www.indec.gob.ar/ftp/cuadros/economia/CNA18_C_'
extension <- '.xlsx'


for (c in 2:7){
        for (sc in 1:33){
                        cuadro <- paste(c,sc,sep='_')
                        url <- paste0(path, cuadro, extension)
                        path_to <- paste0('./tablas_cna_2018/C_', cuadro, extension)
                        download.file(url, path_to, method='curl')
                }
        }
