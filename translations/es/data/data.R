delayedAssign('puntaje_pais',
        eval(parse(file.path(system.file('scripts','country_scores.txt', package = 'casadelalibertad')))))

delayedAssign('estado_calificacion_pais',
        eval(parse(file.path(system.file('scripts','country_rating_statuses.txt', package = 'casadelalibertad')))))
