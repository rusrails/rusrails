# Инструменты командной строки

Варианты написания теста производительности могут быть излишними, когда нужны одноразовые тесты. Rails имеет два инструмента командной строки, которые позволяют быстрое и черновое тестирование производительности:

### `benchmarker`

Использование:

```bash
Usage: rails benchmarker 'Ruby.code' 'Ruby.more_code' ... [OPTS]
    -r, --runs N                     Number of runs.
                                     Default: 4
    -o, --output PATH                Directory to use when writing the results.
                                     Default: tmp/performance
    -m, --metrics a,b,c              Metrics to use.
                                     Default: wall_time,memory,objects,gc_runs,gc_time
```

Пример:

```bash
$ rails benchmarker 'Item.all' 'CouchItem.all' --runs 3 --metrics wall_time,memory
```

### `profiler`

Использование:

```bash
Usage: rails profiler 'Ruby.code' 'Ruby.more_code' ... [OPTS]
    -r, --runs N                     Number of runs.
                                     Default: 1
    -o, --output PATH                Directory to use when writing the results.
                                     Default: tmp/performance
    -m, --metrics a,b,c              Metrics to use.
                                     Default: process_time,memory,objects
    -f, --formats x,y,z              Formats to output to.
                                     Default: flat,graph_html,call_tree
```

Пример:

```bash
$ rails profiler 'Item.all' 'CouchItem.all' --runs 2 --metrics process_time --formats flat
```

NOTE: Метрики и форматы изменяются от интерпретатора к интерпретатору. Передавайте `--help` каждому инструменту, чтобы просмотреть значения по умолчанию для своего интерпретатора.
