from scrapy.commands import ScrapyCommand
from scrapy.crawler import CrawlerProcess
from scrapy.utils.project import get_project_settings
from kingfisher_scrapy.spiders.afghanistan_records import AfghanistanRecords
from kingfisher_scrapy.spiders.argentina_vialidad import ArgentinaVialidad
from kingfisher_scrapy.spiders.armenia import Armenia
from kingfisher_scrapy.spiders.australia import Australia
from kingfisher_scrapy.spiders.australia_nsw import AustraliaNSW
from kingfisher_scrapy.spiders.canada_buyandsell import CanadaBuyAndSell
from kingfisher_scrapy.spiders.canada_montreal import CanadaMontreal
from kingfisher_scrapy.spiders.chile_compra_releases import ChileCompraReleases


class GetLastReleaseDatePerPublisher(ScrapyCommand):
    def short_desc(self):
        return 'Get the last published release date per publisher'

    def run(self, args, opts):
        settings = get_project_settings()
        settings.set('CLOSESPIDER_ITEMCOUNT', 1)
        settings.set('CONCURRENT_REQUESTS', 1)
        process = CrawlerProcess(settings=settings)

        process.crawl(ChileCompraReleases, last='true')
        process.start()
