\docType{data}
\name{puntaje_pais}
\alias{puntaje_pais}
\title{Puntajes Desagregados de la Libertad en el Mundo, 2012-2023}
\format{Un data.frame de 62.875 filas y 10 columnas
\describe{
\item{anio}{Año de la observación (2012-2023)}
\item{pais_territorio}{Nombre del país o territorio}
\item{iso2c}{Código ISO de dos dígitos del país o territorio. Abjasia, Crimea, Kosovo, Nagorno-Karabaj, Osetia del Sur, Palestina, Sahara Occidental y Transnistria no tienen una correspondencia inambigua y aparecen como 'NA'}
\item{iso3c}{Código ISO de tres dígitos del país o territorio. Sigue el mismo criterio para los 'NA' que la variable iso2c.}
\item{continente}{Nombre del continente.}
\item{categoria}{Letra de la categoría (A-G).}
\item{sub_categoria}{Letra y número de la sub-categoría (A1-G4).}
\item{descripcion_categoria}{Descripción de la categoría.}
\item{descripcion_sub_categoria}{Descripción de la sub-categoría.}
\item{puntaje}{Puntaje del sub-ítem (0-4).}
}}
\usage{puntaje_pais}
\description{Además de la tabla estado y ranking, los items mostrados aquí pueden ser sumados para obtener el puntaje agregado de derechos políticos (suma de los items A a C) y libertades civiles (items D a G). Los sub-ítems son puntuados de 0 a 4, con 0 representando el menor grado de logro en una categoría dada y 4 el mayor. Por ejemplo, un país que tiene 36 o más puntos en el puntaje agregado de derechos políticos obtiene una calificación de 1, de 30 a 35 puntos una calificación de 2 y así sucesivamente.}
\source{Adaptado de Freedom House}
\keyword{datasets}
