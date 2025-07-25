using System;
using System.Collections.Generic;
using System.Text;
using Microsoft.AspNetCore.Http;

namespace ScoutTrack.Model.Requests
{
    public class ImageUploadRequest
    {
        public IFormFile? Image { get; set; } = null!;
    }
}
