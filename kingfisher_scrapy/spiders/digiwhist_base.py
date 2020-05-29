import tarfile
from io import BytesIO

from kingfisher_scrapy.base_spider import BaseSpider
from kingfisher_scrapy.util import handle_error


class DigiwhistBase(BaseSpider):
    @handle_error
    def parse(self, response):
        yield self.build_file_from_response(response, 'file.tar.gz', post_to_api=False)

        # Load a line at the time, pass it to API
        with tarfile.open(fileobj=BytesIO(response.body), mode="r:gz") as tar:
            with tar.extractfile(tar.getnames()[0]) as readfp:
                yield from self.parse_json_lines(readfp, 'release_package', self.start_urls[0])
