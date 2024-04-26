\docType{data}
\name{texto_calificacion_pais}
\alias{texto_calificacion_pais}
\title{Libertades Civiles y Derechos Políticos, 1972-2023}
\format{Un data.frame de 29,841 filas y 7 columnas
\describe{
\item{anio}{Año de la observación (2017-2023)}
\item{pais}{Nombre del país o territorio}
\item{iso2c}{Código ISO de dos dígitos del país o territorio. Abjasia, Crimea, Kosovo, Nagorno-Karabaj, Osetia del Sur, Palestina, Sahara Occidental y Transnistria no tienen una correspondencia inambigua y aparecen como 'NA'}
\item{iso3c}{Código ISO de tres dígitos del país o territorio. Sigue el mismo criterio para los 'NA' que la variable iso2c.}
\item{continente}{Nombre del continente.}
\item{sub_categoria}{Letra y número de la sub-categoría (A1-G4) además de 'Cambio en la calificació', 'Descripción general', 'Desarrollos clave', 'Tendencia' y 'Notas'.}
\item{detalle}{Detalles y justificación de la calificación asignada a la sub-categoría.}
}}
\usage{texto_calificacion_pais}
\description{Proporciona el texto de cada subelemento de la tabla de puntajes. Para cada subelemento, el texto corresponde a la justificación de la puntuación asignada.}
\source{Adaptado de Freedom House}
\keyword{datasets}
